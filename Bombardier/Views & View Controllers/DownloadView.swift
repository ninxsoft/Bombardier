//
//  DownloadView.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/5/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class DownloadView: NSView {
  
  let multiplier = CGFloat(0.75)
  
  var inDarkMode: Bool {
    let mode = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
    return mode == "Dark"
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // slightly different shades of blue for light mode and dark mode
    let fillColor = NSColor(calibratedRed: (self.inDarkMode ? 10.0 : 0.0)/255.0, green: (self.inDarkMode ? 132.0 : 122.0)/255.0, blue: 255.0/255.0, alpha: 1.0)
    fillColor.setStroke()
    
    // draw the blue pill
    let path = NSBezierPath()
    path.lineWidth = dirtyRect.height * self.multiplier
    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    path.move(to: NSPoint(x: dirtyRect.width * 0.25, y: dirtyRect.height * 0.5))
    path.line(to: NSPoint(x: dirtyRect.width * 0.75, y: dirtyRect.height * 0.5))
    path.stroke()
  }
  
  func imageRepresentation() -> NSImage? {
    
    guard let representation = self.bitmapImageRepForCachingDisplay(in: self.bounds) else {
      return nil
    }

    let size = self.bounds.size
    representation.size = size
    self.cacheDisplay(in: self.bounds, to: representation)
    let image = NSImage(size: size)
    image.addRepresentation(representation)
    return image
  }
}
