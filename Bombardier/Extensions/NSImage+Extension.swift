//
//  NSImage+Extension.swift
//  Bombardier
//
//  Created by Nindi Gill on 6/7/20.
//

import Cocoa

extension NSImage {

  func resized(width: CGFloat, height: CGFloat) -> NSImage? {
    let image: NSImage = NSImage(size: NSSize(width: width, height: height))
    image.lockFocus()

    guard let context: NSGraphicsContext = NSGraphicsContext.current else {
      return nil
    }

    context.imageInterpolation = .high
    let inRect: NSRect = NSRect(x: 0, y: 0, width: width, height: height)
    let fromRect: NSRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
    self.draw(in: inRect, from: fromRect, operation: .copy, fraction: 1)
    image.unlockFocus()
    image.isTemplate = self.isTemplate
    return image
  }
}
