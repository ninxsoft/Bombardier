//
//  AppCommands.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/8/20.
//

import SwiftUI

struct AppCommands: Commands {
    @Environment(\.openURL) var openURL: OpenURLAction

    @CommandsBuilder var body: some Commands {
        CommandGroup(replacing: .help) {
            Button("Bombardier Help") {
                help()
            }
        }
        CommandGroup(replacing: .saveItem) {
            Button("Close") {
                close()
            }
            .keyboardShortcut("w", modifiers: .command)
        }
        CommandGroup(replacing: .systemServices) { }
    }

    func help() {

        let string: String = "https://github.com/ninxsoft/Bombardier"

        guard let url: URL = URL(string: string) else {
            return
        }

        openURL(url)
    }

    func close() {
        NSApplication.shared.keyWindow?.close()
    }
}
