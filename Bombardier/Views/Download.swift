//
//  Download.swift
//  Bombardier
//
//  Created by Nindi Gill on 6/7/20.
//

import SwiftUI
import Combine

struct Download_Previews: PreviewProvider {
  static var previews: some View {
    Download(package: .example)
  }
}

struct Download: View {
  @EnvironmentObject var preferences: Preferences
  var package: Package
  @StateObject var downloader: Downloader = Downloader.shared
  @StateObject var extracter: Extracter = Extracter.shared
  @State var totalBytesWritten: CGFloat = 0
  private let width: CGFloat = 360
  private let height: CGFloat = 200
  private let leadingImageLength: CGFloat = 48
  private let trailingImageLength: CGFloat = 32
  var progress: CGFloat {
    return totalBytesWritten / CGFloat(package.size)
  }
  var formattedProgress: String {
    let currentMB: CGFloat = totalBytesWritten / 1000 / 1000
    let totalMB: CGFloat = CGFloat(package.size) / 1000 / 1000
    let percentage: CGFloat = progress * 100
    let string: String = String(format: "%.1f MB of %.1f MB (%.1f%%)", currentMB, totalMB, percentage)
    return string
  }
  private let timer: Publishers.Autoconnect<Timer.TimerPublisher> = Timer.publish(every: 0.25,
                                                                                  on: .current,
                                                                                  in: .common).autoconnect()

  var body: some View {
    VStack {
      Text(package.name)
        .font(.title2)
        .padding(.bottom)
      HStack {
        Image(nsImage: Images.shared.package(width: leadingImageLength, height: leadingImageLength))
          .resizable()
          .frame(width: leadingImageLength, height: leadingImageLength)
          .padding(.trailing)
        VStack(alignment: .leading) {
          Text("Downloading...")
            .fontWeight(.semibold)
          Text(formattedProgress)
            .onReceive(timer) { _ in
              totalBytesWritten = downloader.finished && !downloader.failed ? CGFloat(package.size) :
                downloader.totalBytesWritten
            }
        }
        Spacer()
        ZStack {
          if !downloader.finished {
            ProgressView(value: progress)
              .progressViewStyle(CircularProgressViewStyle())
          } else {
            ZStack {
              Circle()
                .foregroundColor(.white)
                .frame(width: trailingImageLength * 0.75, height: trailingImageLength * 0.75)
              Image(systemName: downloader.failed ? "xmark.seal.fill" : "checkmark.seal.fill")
                .resizable()
                .frame(width: trailingImageLength, height: trailingImageLength)
                .foregroundColor(downloader.failed ? .red : .green)
            }
          }
        }
      }
      Spacer()
      if downloader.finished {
        HStack {
          Image(nsImage: Images.shared.dmg(width: leadingImageLength, height: leadingImageLength))
            .resizable()
            .frame(width: leadingImageLength, height: leadingImageLength)
            .padding(.trailing)
          VStack(alignment: .leading) {
            Text("Extracting...")
              .fontWeight(.semibold)
          }
          Spacer()
          ZStack {
            if !extracter.finished {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            } else {
              ZStack {
                Circle()
                  .foregroundColor(.white)
                  .frame(width: trailingImageLength * 0.75, height: trailingImageLength * 0.75)
                Image(systemName: extracter.failed ? "xmark.seal.fill" : "checkmark.seal.fill")
                  .resizable()
                  .frame(width: trailingImageLength, height: trailingImageLength)
                  .foregroundColor(extracter.failed ? .red : .green)
              }
            }
          }
        }
      }
      Button(!downloader.finished || !extracter.finished ? "Cancel" : "Close", action: {

        guard downloader.finished && extracter.finished else {
          downloader.cancel()
          extracter.cancel()
          return
        }

        preferences.sheetPresented = false
      })
      .padding(.top)
    }
    .frame(minWidth: width, maxWidth: width, minHeight: height, maxHeight: height)
    .padding()
    .onAppear {
      downloader.download(package: package)
    }
    .onChange(of: downloader.finished, perform: { _ in

      guard downloader.finished && !downloader.failed else {
        return
      }

      extracter.extract(package, to: Preferences.shared.downloadsDirectory)
    })
    .onChange(of: extracter.finished, perform: { _ in

      guard extracter.finished && !extracter.failed else {
        return
      }

      NSWorkspace.shared.selectFile(preferences.downloadPath(for: package),
                                    inFileViewerRootedAtPath: "")
    })
  }
}
