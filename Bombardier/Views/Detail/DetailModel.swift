//
//  DetailModel.swift
//  Bombardier
//
//  Created by Nindi Gill on 8/7/20.
//

import SwiftUI

struct DetailModel: View {
    var model: Model
    var packages: [Package]

    var body: some View {
        VStack {
            DetailModelRow(model: model)
            HStack {
                Text("Supported Packages:")
                    .font(.title3)
                Spacer()
            }
            .padding(.top)
            ScrollView(.vertical) {
                ForEach(packages) { package in
                    DetailPackageRow(package: package)
                }
            }
        }
        .padding()
    }
}

struct DetailModel_Previews: PreviewProvider {
    static var previews: some View {
        DetailModel(model: .example, packages: [.example])
    }
}
