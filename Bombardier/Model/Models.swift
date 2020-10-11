//
//  Models.swift
//  Bombardier
//
//  Created by Nindi Gill on 5/7/20.
//

import Foundation

struct Model: Identifiable, Hashable {

    enum Family: String, CaseIterable, Identifiable {
        case imac = "iMac"
        case imacpro = "iMacPro"
        case macbook = "MacBook"
        case macbookair = "MacBookAir"
        case macbookpro = "MacBookPro"
        case macmini = "Macmini"
        case macpro = "MacPro"

        // swiftlint:disable:next identifier_name
        var id: String {
            rawValue
        }

        var description: String {
            switch self {
            case .imac:
                return "iMac"
            case .imacpro:
                return "iMac Pro"
            case .macbook:
                return "MacBook"
            case .macbookair:
                return "MacBook Air"
            case .macbookpro:
                return "MacBook Pro"
            case .macmini:
                return "Mac mini"
            case .macpro:
                return "Mac Pro"
            }
        }
    }

    static var example: Model {
        let name: String = "iMac Pro (2017)"
        let modelIdentifier: String = "iMacPro1,1"
        let imageName: String = "com.apple.imacpro-2017.icns"
        let model: Model = Model(name: name, modelIdentifier: modelIdentifier, imageName: imageName)
        return model
    }

    // swiftlint:disable:next identifier_name
    let id: String = UUID().uuidString
    let name: String
    let modelIdentifier: String
    let imageName: String
    var family: Family? {
        let string: String = modelIdentifier.components(separatedBy: .decimalDigits).joined()
            .replacingOccurrences(of: ",", with: "")
        return Family(rawValue: string)
    }

    func supportedPackages(from packages: [Package]) -> [Package] {
        packages.filter {
            $0.modelIdentifiers.contains(modelIdentifier)
        }
    }
}

class Models {

    static let urlPath: String = "https://raw.githubusercontent.com/ninxsoft/Bombardier/master/MacModels.plist"

    static func models(from dictionary: NSDictionary) -> [Model] {

        var models: [Model] = []

        guard let modelDictionaries: [[String: Any]] = dictionary.object(forKey: "Models") as? [[String: Any]] else {
            return models
        }

        for modelDictionary in modelDictionaries {

            guard let modelIdentifier: String = modelDictionary["ModelIdentifier"] as? String,
                let name: String = modelDictionary["MarketingName"] as? String,
                let imageName: String = modelDictionary["ImagePath"] as? String else {
                continue
            }

            let model: Model = Model(name: name, modelIdentifier: modelIdentifier, imageName: imageName)
            models.append(model)
        }

        return models
    }

    static func lastUpdated(from dictionary: NSDictionary) -> Date {

        guard let date: Date = dictionary.object(forKey: "LastUpdated") as? Date else {
            return Date()
        }

        return date
    }
}
