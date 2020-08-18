//
//  PreferencesView.swift
//  Bombardier
//
//  Created by Nindi Gill on 3/7/20.
//

import SwiftUI

struct PreferencesView_Previews: PreviewProvider {
  static var previews: some View {
    PreferencesView()
  }
}

struct PreferencesView: View {
  @StateObject private var preferences: Preferences = Preferences.shared
  private let width: CGFloat = 600
  private let height: CGFloat = 200
  private let textEditorHeight: CGFloat = 50
  private let panel: NSOpenPanel = NSOpenPanel()

  var body: some View {
    VStack {
      HStack {
        Text("Software Update Catalog URL:")
          .bold()
        Spacer()
        Button("Reset") {
          preferences.softwareUpdateCatalogURL = Preferences.defaultSoftwareUpdateCatalogURL
        }
      }
      TextEditor(text: $preferences.softwareUpdateCatalogURL)
        .frame(height: textEditorHeight)
        .onChange(of: preferences.softwareUpdateCatalogURL) { value in
          UserDefaults.standard.set(value, forKey: Key.softwareUpdateCatalogURL)
        }
      Spacer()
      HStack {
        Text("Downloads Directory:")
          .bold()
        Spacer()
        Button("Select...") {
          showOpenPanel()
        }
      }
      HStack {
        PreferencesPathControl(bookmarkData: preferences.downloadsDirectoryBookmarkData)
        Spacer()
      }
    }
    .padding()
    .frame(minWidth: width, maxWidth: width, minHeight: height, maxHeight: height)
  }

  private func showOpenPanel() {
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = true
    panel.canChooseFiles = false
    panel.canDownloadUbiquitousContents = false
    panel.canResolveUbiquitousConflicts = false
    panel.isAccessoryViewDisclosed = true
    panel.resolvesAliases = true

    panel.begin(completionHandler: { response in

      guard response == .OK,
        let url: URL = panel.url else {
        return
      }

      do {
        let data: Data = try url.bookmarkData()
        preferences.downloadsDirectoryBookmarkData = data
        UserDefaults.standard.set(data, forKey: Key.downloadsDirectoryBookmarkData)
      } catch {
        print(error)
      }
    })
  }
}
