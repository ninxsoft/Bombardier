//
//  Packages.swift
//  Bombardier
//
//  Created by Nindi Gill on 5/7/20.
//

import Foundation

struct Package: Identifiable, Hashable {

    static var example: Package {
        let name: String = "000-123456"
        let version: String = "1.2.3456"
        let size: Int = 1234567890
        let date: Date = Date()
        let urlPath: String = "https://example.com"
        let digest: String = "abcdef0123456789"
        let modelIdentifiers: [String] = []
        let package: Package = Package(name: name, version: version, size: size, date: date, urlPath: urlPath, digest: digest, modelIdentifiers: modelIdentifiers)
        return package
    }

    // swiftlint:disable:next identifier_name
    let id: String = UUID().uuidString
    let name: String
    let version: String
    let size: Int
    let date: Date
    let urlPath: String
    let digest: String
    let modelIdentifiers: [String]
    var formattedSize: String {
        String(format: "%.1f MB", Double(size) / 1000 / 1000)
    }

    func formattedDate(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        let string: String = dateFormatter.string(from: date)
        return string
    }

    func supportedModels(from models: [Model]) -> [Model] {
        models.filter {
            modelIdentifiers.contains($0.modelIdentifier)
        }
    }
}

class Packages {

    private static func modelIdentifiers(from distributionURL: String) -> [String] {

        var modelIdentifiers: [String] = []
        let seperator: String = "*"

        guard let url = URL(string: distributionURL) else {
            return modelIdentifiers
        }

        do {
            let contents: String = try String(contentsOf: url)
            var string: String = contents

            if let startIndex: String.Index = string.range(of: "var models = ['", options: [])?.upperBound {
                var substring: Substring = string[startIndex...]
                string = String(substring)

                if let endIndex: String.Index = string.range(of: "',];", options: [])?.lowerBound {
                    substring = string[..<endIndex]
                    string = String(substring)
                    string = string.replacingOccurrences(of: "','", with: seperator)
                    modelIdentifiers = string.components(separatedBy: seperator)
                }
            }
        } catch {
            print(error.localizedDescription)
        }

        return modelIdentifiers.sorted { $0 < $1 }
    }

    static func packages(from products: [String: Any], with packageDictionaries: [[String: Any]]) -> [Package] {

        var packages: [Package] = []

        for (name, product) in products {

            if let productDictionary: [String: Any] = product as? [String: Any],
                let serverMetadataURL: String = productDictionary["ServerMetadataURL"] as? String,
                serverMetadataURL.contains("BootCamp"),
                let date: Date = productDictionary["PostDate"] as? Date,
                let packagesDictionary: [Any] = productDictionary["Packages"] as? [Any],
                let packageDictionary: [String: Any] = packagesDictionary.first as? [String: Any],
                let size: Int = packageDictionary["Size"] as? Int,
                let urlPath: String = packageDictionary["URL"] as? String,
                let digest: String = packageDictionary["Digest"] as? String,
                let distributions: [String: Any] = productDictionary["Distributions"] as? [String: Any],
                let distributionURL: String = distributions["English"] as? String {

                var version: String = "Unknown"

                for dictionary in packageDictionaries {

                    if let packageName: String = dictionary["PackageName"] as? String,
                        let bootCampVersion: String = dictionary["BootCampVersion"] as? String,
                        packageName == name {
                        version = bootCampVersion
                        break
                    }
                }

                let modelIdentifiers: [String] = self.modelIdentifiers(from: distributionURL)
                let package: Package = Package(name: name, version: version, size: size, date: date, urlPath: urlPath, digest: digest, modelIdentifiers: modelIdentifiers)
                packages.append(package)
            }
        }

        return packages.sorted { $0.name < $1.name }
    }
}
