//
//  DetailPackageRow.swift
//  Bombardier
//
//  Created by Nindi Gill on 10/7/20.
//

import SwiftUI

struct DetailPackageRow: View {
    @EnvironmentObject var preferences: Preferences
    var package: Package
    private var imageName: String {
        Preferences.shared.exists(package: package) ? "magnifyingglass.circle.fill" : "arrow.down.circle.fill"
    }
    private let leadingImageLength: CGFloat = 64
    private let trailingImageLength: CGFloat = 36

    var body: some View {
        GroupBox {
            HStack {
                Image(nsImage: Images.shared.image(path: Images.packagePath, width: leadingImageLength, height: leadingImageLength))
                    .resizable()
                    .scaledToFit()
                    .frame(width: leadingImageLength, height: leadingImageLength)
                VStack(alignment: .trailing) {
                    Text("Name:")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Version:")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Size:")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Last Updated:")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                VStack(alignment: .leading) {
                    Text(package.name)
                        .font(.title3)
                    Text(package.version)
                        .font(.title3)
                    Text(package.formattedSize)
                        .font(.title3)
                    Text(package.formattedDate(dateStyle: .full, timeStyle: .long))
                        .font(.title3)
                }
                Spacer()
                Button(action: {
                    if Preferences.shared.exists(package: package) {
                        NSWorkspace.shared.selectFile(Preferences.shared.downloadPath(for: package), inFileViewerRootedAtPath: "")
                    } else {
                        preferences.selectedPackage = package
                        preferences.sheet = .download
                        preferences.sheetPresented = true
                    }
                }, label: {
                    ZStack {
                        Circle()
                            .foregroundColor(.white)
                            .frame(width: trailingImageLength, height: trailingImageLength)
                        Image(systemName: imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: trailingImageLength, height: trailingImageLength)
                            .foregroundColor(.accentColor)
                    }
                })
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
        }
    }
}

struct DetailPackageRow_Previews: PreviewProvider {
    static var previews: some View {
        DetailPackageRow(package: .example)
    }
}
