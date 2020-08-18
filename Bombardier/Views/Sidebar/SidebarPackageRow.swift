//
//  SidebarPackageRow.swift
//  Bombardier
//
//  Created by Nindi Gill on 5/7/20.
//

import SwiftUI

struct SidebarPackageRow_Previews: PreviewProvider {
  static var previews: some View {
    SidebarPackageRow(package: .example)
  }
}

struct SidebarPackageRow: View {
  var package: Package
  private let leadingImageLength: CGFloat = 48
  private let trailingImageLength: CGFloat = 32

  var body: some View {
    HStack {
      Image(nsImage: Images.shared.package(width: leadingImageLength, height: leadingImageLength))
        .resizable()
        .scaledToFit()
        .frame(width: leadingImageLength, height: leadingImageLength)
      VStack(alignment: .leading) {
        Text(package.name)
          .bold()
        Text(package.formattedDate(dateStyle: .long, timeStyle: .long))
      }
      Spacer()
      if Preferences.shared.exists(package: package) {
        ZStack {
          Circle()
            .foregroundColor(.white)
            .frame(width: trailingImageLength * 0.75, height: trailingImageLength * 0.75)
          Image(systemName: "checkmark.seal.fill")
            .resizable()
            .frame(width: trailingImageLength, height: trailingImageLength)
            .foregroundColor(.green)
        }
      }
    }
    .padding(.vertical)
  }
}
