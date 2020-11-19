//
//  PreferencesPathControl.swift
//  Bombardier
//
//  Created by Nindi Gill on 6/7/20.
//

import SwiftUI

struct PreferencesPathControl: NSViewRepresentable {

    class Coordinator: NSObject {
        var parent: PreferencesPathControl

        init(_ parent: PreferencesPathControl) {
            self.parent = parent
        }
    }

    var bookmarkData: Data

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSPathControl {
        let pathControl: NSPathControl = NSPathControl(frame: .zero)
        pathControl.pathStyle = .standard
        pathControl.isEditable = false
        pathControl.focusRingType = .none
        pathControl.url = bookmarkData.downloadsDirectoryURL
        return pathControl
    }

    func updateNSView(_ nsView: NSPathControl, context: Context) {
        nsView.url = bookmarkData.downloadsDirectoryURL
    }
}

struct SettingsPathControl_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesPathControl(bookmarkData: Data())
    }
}
