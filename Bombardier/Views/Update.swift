//
//  Update.swift
//  Bombardier
//
//  Created by Nindi Gill on 5/7/20.
//

import SwiftUI

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
                Image(nsImage: Images.shared.image(path: Images.modelPath + "com.apple.imacpro-2017.icns", width: leadingImageLength, height: leadingImageLength))
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
                                .frame(width: trailingImageLength * 0.75, height: trailingImageLength * 0.75)
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
                Image(nsImage: Images.shared.image(path: Images.packagePath, width: leadingImageLength, height: leadingImageLength))
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
            Button(modelsLoading || packagesLoading ? "Cancel" : "Close") {
                preferences.sheetPresented = false
            }
            .padding(.top)
        }
        .frame(minWidth: width, maxWidth: width, minHeight: height, maxHeight: height)
        .padding()
        .onAppear {
            update()
        }
    }

    private func update() {

        guard let bombardierURL = URL(string: Preferences.bombardierURL),
            let catalogURL = URL(string: Preferences.shared.softwareUpdateCatalogURL) else {
            finish(models: true, packages: true)
            return
        }

        let bombardierTask: URLSessionDownloadTask = URLSession.shared.downloadTask(with: bombardierURL) { url, _, error in

            if let error: Error = error {
                print(error)
                finish(models: true, packages: true)
                return
            }

            guard let url = url,
                let dictionary: NSDictionary = NSDictionary(contentsOf: url),
                let lastUpdated: Date = dictionary.object(forKey: "LastUpdated") as? Date,
                let modelsArray: [[String: Any]] = dictionary.object(forKey: "Models") as? [[String: Any]],
                let packagesArray: [[String: Any]] = dictionary.object(forKey: "Packages") as? [[String: Any]] else {
                finish(models: true, packages: true)
                return
            }

            modelsLoading = false
            modelsLastUpdated = lastUpdated

            let packagesTask: URLSessionDownloadTask = URLSession.shared.downloadTask(with: catalogURL) { url, _, error  in

                if let error: Error = error {
                    print(error)
                    finish(models: false, packages: true)
                    return
                }

                guard let url = url,
                    let dictionary = NSDictionary(contentsOf: url),
                    let lastUpdated: Date = dictionary.object(forKey: "IndexDate") as? Date,
                    let products: [String: Any] = dictionary.object(forKey: "Products") as? [String: Any] else {
                    finish(models: false, packages: true)
                    return
                }

                packagesLoading = false
                packagesLastUpdated = lastUpdated
                packages = Packages.packages(from: products, with: packagesArray)
                models = Models.models(from: modelsArray)
            }

            packagesTask.resume()
        }

        bombardierTask.resume()
    }

    private func finish(models: Bool, packages: Bool) {
        modelsLoading = false
        modelsFailed = models
        packagesLoading = false
        packagesFailed = packages
    }
}

struct Update_Previews: PreviewProvider {
    static var previews: some View {
        Update(models: .constant([]), packages: .constant([]))
    }
}
