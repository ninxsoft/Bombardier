//
//  Images.swift
//  Bombardier
//
//  Created by Nindi Gill on 7/7/20.
//

import Cocoa

class Images {

    static let shared: Images = Images()
    static let modelPath: String = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/"
    static let packagePath: String = "/System/Library/CoreServices/Installer.app/Contents/Resources/package.icns"
    static let dmgPath: String = "/System/Library/CoreServices/DiskImageMounter.app/Contents/Resources/diskcopy-doc.icns"
    private var modelsArray: [(name: String, image: NSImage)] = []

    init() {

        do {
            let names: [String] = try FileManager.default.contentsOfDirectory(atPath: Images.modelPath)

            for name in names where name.contains("imac") ||
                name.contains("macpro") ||
                name.contains("macmini") ||
                name.contains("macbook") {

                if let image: NSImage = NSImage(contentsOfFile: Images.modelPath + name) {
                    let tuple: (name: String, image: NSImage) = (name: name, image: image)
                    modelsArray.append(tuple)
                }
            }
        } catch {
            print(error)
        }
    }

    func image(path: String, width: CGFloat, height: CGFloat) -> NSImage {

        guard let image: NSImage = NSImage(contentsOfFile: path),
            let resizedImage: NSImage = image.resized(width: width, height: height) else {
            return NSApplication.shared.applicationIconImage
        }

        return resizedImage
    }

    func modelImage(for name: String, width: CGFloat, height: CGFloat) -> NSImage {

        for model in modelsArray where model.name == name {

            guard let resizedImage: NSImage = model.image.resized(width: width, height: height) else {
                return NSApplication.shared.applicationIconImage
            }

            return resizedImage
        }

        return NSApplication.shared.applicationIconImage
    }
}
