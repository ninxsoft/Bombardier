//
//  DisplayType.swift
//  Bombardier
//
//  Created by Nindi Gill on 5/7/20.
//

import Foundation

enum DisplayType: String, Identifiable, CaseIterable {
    case models = "Mac Models"
    case packages = "Boot Camp Packages"

    // swiftlint:disable:next identifier_name
    var id: String {
        rawValue
    }

    var description: String {
        rawValue
    }
}
