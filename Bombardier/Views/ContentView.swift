//
//  ContentView.swift
//  Bombardier
//
//  Created by Nindi Gill on 3/7/20.
//

import SwiftUI

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct ContentView: View {
  @EnvironmentObject var preferences: Preferences
  @State private var displayType: DisplayType = .models
  @State private var models: [Model] = []
  @State private var selectedModel: Model?
  @State private var packages: [Package] = []
  @State private var selectedPackage: Package?
  private let height: CGFloat = 720

  var body: some View {
    HStack(spacing: 0) {
      Sidebar(displayType: $displayType,
              models: models,
              selectedModel: $selectedModel,
              packages: packages,
              selectedPackage: $selectedPackage)
      Divider()
      Detail(displayType: displayType, models: models,
             selectedModel: selectedModel,
             packages: packages,
             selectedPackage: selectedPackage)
    }
    .onAppear {
      preferences.sheet = .update
      preferences.sheetPresented = true
    }
    .sheet(isPresented: $preferences.sheetPresented) {
      switch preferences.sheet {
      case .update:
        Update(models: $models, packages: $packages)
      case .download:
        Download(package: preferences.selectedPackage)
      }
    }
    .toolbar {
      ToolbarItem {
        Button(action: {
          preferences.sheet = .update
          preferences.sheetPresented = true
        }, label: {
          Image(systemName: "arrow.clockwise")
            .foregroundColor(.accentColor)
        })
      }
    }
    .frame(minHeight: height, maxHeight: .infinity)
  }
}
