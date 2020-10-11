//
//  DetailModelRow.swift
//  Bombardier
//
//  Created by Nindi Gill on 10/7/20.
//

import SwiftUI

struct DetailModelRow: View {
    var model: Model
    private let length: CGFloat = 64

    var body: some View {
        GroupBox {
            HStack {
                Image(nsImage: Images.shared.modelImage(for: model.imageName, width: length, height: length))
                    .resizable()
                    .scaledToFit()
                    .frame(width: length, height: length)
                VStack(alignment: .leading) {
                    Text(model.name)
                        .font(.title2)
                    HStack {
                        Text("Model Identifier:")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(model.modelIdentifier)
                            .font(.title3)
                            .frame(alignment: .leading)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct DetailModelRow_Previews: PreviewProvider {
    static var previews: some View {
        DetailModelRow(model: .example)
    }
}
