//
//  DetailPackage.swift
//  Bombardier
//
//  Created by Nindi Gill on 8/7/20.
//

import SwiftUI

struct DetailPackage: View {
    var package: Package
    var models: [Model]

    var body: some View {
        VStack {
            DetailPackageRow(package: package)
            HStack {
                Text("Supported Macs:")
                    .font(.title3)
                Spacer()
            }
            .padding(.top)
            ScrollView(.vertical) {
                ForEach(models) { model in
                    DetailModelRow(model: model)
                }
            }
        }
        .padding()
    }
}

struct DetailPackage_Previews: PreviewProvider {
    static var previews: some View {
        DetailPackage(package: .example, models: [.example])
    }
}
