//
//  Detail.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/8/20.
//

import SwiftUI

struct Detail_Previews: PreviewProvider {
  static var previews: some View {
    Detail(displayType: .models, models: [.example], selectedModel: nil, packages: [.example], selectedPackage: nil)
  }
}

struct Detail: View {
  var displayType: DisplayType
  var models: [Model]
  var selectedModel: Model?
  var packages: [Package]
  var selectedPackage: Package?
  private let width: CGFloat = 800

  var body: some View {
    VStack {
      switch displayType {
      case .models:
        if selectedModel == nil {
          Text("Select a Mac Model")
            .font(.title)
            .foregroundColor(.gray)
        } else {
          ForEach(models) { model in
            if model == selectedModel {
              DetailModel(model: model, packages: model.supportedPackages(from: packages))
            }
          }
        }
      case .packages:
        if selectedPackage == nil {
          Text("Select a Boot Camp Package")
            .font(.title)
            .foregroundColor(.gray)
        } else {
          ForEach(packages) { package in
            if package == selectedPackage {
              DetailPackage(package: package, models: package.supportedModels(from: models))
            }
          }
        }
      }
    }
    .frame(minWidth: width, maxWidth: .infinity, maxHeight: .infinity)

  }
}
