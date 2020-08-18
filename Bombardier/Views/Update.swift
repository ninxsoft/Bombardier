//
//  Update.swift
//  Bombardier
//
//  Created by Nindi Gill on 5/7/20.
//

import SwiftUI

struct Update_Previews: PreviewProvider {
  static var previews: some View {
    Update(models: .constant([]), packages: .constant([]))
  }
}

struct Update: View {
  @EnvironmentObject var preferences: Preferences
  @Binding var models: [Model]
  @Binding var packages: [Package]
  @State private var modelsLoading: Bool = true
  @State private var modelsFailed: Bool = false
  @State private var modelsLastUpdated: Date = Date.distantPast
  @State private var packagesLoading: Bool = true
  @State private var packagesFailed: Bool = false
  @State private var packagesLastUpdated: Date = Date.distantPast
  private let width: CGFloat = 360
  private let height: CGFloat = 200
  private let leadingImageLength: CGFloat = 48
  private let trailingImageLength: CGFloat = 32
  private var modelDescription: String {

    guard !modelsLoading else {
      return "Downloading"
    }

    guard !modelsFailed else {
      return "Error downloading Models"
    }

    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    let string: String = dateFormatter.string(from: modelsLastUpdated)
    return string
  }
  private var packagesDescription: String {

    guard !packagesLoading else {
      return "Downloading"
    }

    guard !packagesFailed else {
      return "Error downloading Catalog"
    }

    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    let string: String = dateFormatter.string(from: packagesLastUpdated)
    return string
  }

  var body: some View {
    VStack {
      Text("Updating")
        .foregroundColor(.primary)
        .font(.title2)
        .padding(.bottom)
      HStack {
        Image(nsImage: Images.shared.model(width: leadingImageLength, height: leadingImageLength))
          .resizable()
          .frame(width: leadingImageLength, height: leadingImageLength)
          .padding(.trailing)
        VStack(alignment: .leading) {
          Text("Mac Models")
            .fontWeight(.semibold)
          Text(modelDescription)
        }
        Spacer()
        ZStack {
          if modelsLoading {
            ProgressView()
          } else {
            ZStack {
              Circle()
                .foregroundColor(.white)
                .frame(width: trailingImageLength * 0.75, height: trailingImageLength / 2)
              Image(systemName: modelsFailed ? "xmark.seal.fill" : "checkmark.seal.fill")
                .resizable()
                .frame(width: trailingImageLength, height: trailingImageLength)
                .foregroundColor(modelsFailed ? .red : .green)
            }
          }
        }
      }
      Spacer()
      HStack {
        Image(nsImage: Images.shared.package(width: leadingImageLength, height: leadingImageLength))
          .resizable()
          .frame(width: leadingImageLength, height: leadingImageLength)
          .padding(.trailing)
        VStack(alignment: .leading) {
          Text("Boot Camp Packages")
            .fontWeight(.semibold)
          Text(packagesDescription)
        }
        Spacer()
        ZStack {
          if packagesLoading {
            ProgressView()
          } else {
            ZStack {
              Circle()
                .foregroundColor(.white)
                .frame(width: trailingImageLength * 0.75, height: trailingImageLength * 0.75)
              Image(systemName: packagesFailed ? "xmark.seal.fill" : "checkmark.seal.fill")
                .resizable()
                .frame(width: trailingImageLength, height: trailingImageLength)
                .foregroundColor(packagesFailed ? .red : .green)
            }
          }
        }
      }
      Button(modelsLoading || packagesLoading ? "Cancel" : "Close", action: {
        preferences.sheetPresented = false
      })
      .padding(.top)
    }
    .frame(minWidth: width, maxWidth: width, minHeight: height, maxHeight: height)
    .padding()
    .onAppear {
      update()
    }
  }

  private func update() {

    guard let modelsURL = URL(string: Models.urlPath),
          let packagesURL = URL(string: Preferences.shared.softwareUpdateCatalogURL) else {
      finish(modelsFailed: true, packagesFailed: true)
      return
    }

    let modelsTask: URLSessionDownloadTask = URLSession.shared.downloadTask(with: modelsURL) { url, _, error in

      if let error: Error = error {
        print(error)
        finish(modelsFailed: true, packagesFailed: true)
        return
      }

      guard let url = url,
        let modelsDictionary = NSDictionary(contentsOf: url) else {
        finish(modelsFailed: true, packagesFailed: true)
        return
      }

      modelsLoading = false
      modelsLastUpdated = Models.lastUpdated(from: modelsDictionary)

      let packagesTask: URLSessionDownloadTask = URLSession.shared.downloadTask(with: packagesURL) { url, _, error  in

        if let error: Error = error {
          print(error)
          finish(modelsFailed: false, packagesFailed: true)
          return
        }

        guard let url = url,
          let packagesDictionary = NSDictionary(contentsOf: url) else {
          finish(modelsFailed: false, packagesFailed: true)
          return
        }

        packagesLoading = false
        packagesLastUpdated = Packages.lastUpdated(from: packagesDictionary)
        packages = Packages.packages(from: packagesDictionary)
        models = Models.models(from: modelsDictionary)
      }

      packagesTask.resume()
    }

    modelsTask.resume()
  }

  private func finish(modelsFailed: Bool, packagesFailed: Bool) {
    self.modelsLoading = false
    self.modelsFailed = modelsFailed
    self.packagesLoading = false
    self.packagesFailed = packagesFailed
  }
}