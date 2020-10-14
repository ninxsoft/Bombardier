//
//  Preferences.swift
//  Bombardier
//
//  Created by Nindi Gill on 3/7/20.
//

import Foundation

class Preferences: ObservableObject {

    enum Sheet: String {
        case update = "Update"
        case download = "Download"
    }

    static let shared: Preferences = Preferences()
    // swiftlint:disable:next line_length
    static let defaultSoftwareUpdateCatalogURL: String = "https://swscan.apple.com/content/catalogs/others/index-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"
    static let defaultDownloadsDirectory: String = NSHomeDirectory() + "/Downloads/Bombardier"
    static let bombardierURL: String = "https://raw.githubusercontent.com/ninxsoft/Bombardier/master/Bombardier.plist"
    @Published var softwareUpdateCatalogURL: String = Preferences.defaultSoftwareUpdateCatalogURL
    @Published var downloadsDirectoryBookmarkData: Data = Data()
    @Published var sheet: Sheet = .update
    @Published var sheetPresented: Bool = false
    @Published var selectedPackage: Package = .example
    var downloadsDirectory: String {

        var isStale: Bool = false
        var path: String = Preferences.defaultDownloadsDirectory

        do {
            let url: URL = try URL(resolvingBookmarkData: downloadsDirectoryBookmarkData, bookmarkDataIsStale: &isStale)
            path = url.path
        } catch {
            print(error.localizedDescription)
        }

        return path
    }

    init() {
        if let string: String = UserDefaults.standard.string(forKey: Key.softwareUpdateCatalogURL), !string.isEmpty {
            softwareUpdateCatalogURL = string
        } else {
            UserDefaults.standard.set(Preferences.defaultSoftwareUpdateCatalogURL, forKey: Key.softwareUpdateCatalogURL)
        }

        if let data: Data = UserDefaults.standard.data(forKey: Key.downloadsDirectoryBookmarkData),
            !data.isEmpty {
            downloadsDirectoryBookmarkData = data
        } else {

            let url: URL = URL(fileURLWithPath: Preferences.defaultDownloadsDirectory)

            do {
                try FileManager.default.createDirectory(atPath: Preferences.defaultDownloadsDirectory, withIntermediateDirectories: false, attributes: nil)
                let data: Data = try url.bookmarkData()
                UserDefaults.standard.set(data, forKey: Key.downloadsDirectoryBookmarkData)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func downloadPath(for package: Package) -> String {
        let path: String = downloadsDirectory + "/" + package.name + ".dmg"
        return path
    }

    func exists(package: Package) -> Bool {
        let path: String = downloadPath(for: package)
        return FileManager.default.fileExists(atPath: path)
    }
}
