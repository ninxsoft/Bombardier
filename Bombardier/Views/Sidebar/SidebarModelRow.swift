//
//  SidebarModelRow.swift
//  Bombardier
//
//  Created by Nindi Gill on 5/7/20.
//

import SwiftUI

struct SidebarModelRow_Previews: PreviewProvider {
  static var previews: some View {
    SidebarModelRow(model: .example)
  }
}

struct SidebarModelRow: View {
  var model: Model
  private let length: CGFloat = 48

  var body: some View {
    HStack {
      Image(nsImage: Images.shared.modelImage(for: model.imageName, width: length, height: length))
        .resizable()
        .scaledToFit()
        .frame(width: length, height: length)
      VStack(alignment: .leading) {
        Text(model.name)
          .bold()
        Text(model.modelIdentifier)
      }
      Spacer()
    }
    .padding(.vertical)
  }
}
