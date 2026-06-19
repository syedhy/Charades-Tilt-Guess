import AppKit
import Foundation

let fm = FileManager.default
let srcDir = "/Users/hyder/.gemini/antigravity/brain/d68e3b18-0d8b-43ae-93b0-2b1b5149e54c"
let destDir = "CharadesTiltGuess/Assets.xcassets/KidsMode"

try? fm.createDirectory(atPath: destDir, withIntermediateDirectories: true, attributes: nil)

func processImage(_ imagePath: String, outPath: String) {
    guard let image = NSImage(contentsOfFile: imagePath),
          let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData) else {
        print("Failed to load \(imagePath)")
        return
    }

    let width = bitmap.pixelsWide
    let height = bitmap.pixelsHigh
    var minX = width, minY = height, maxX = 0, maxY = 0

    // Make white transparent and find bounding box
    for y in 0..<height {
        for x in 0..<width {
            let color = bitmap.colorAt(x: x, y: y) ?? NSColor.white
            let r = color.redComponent
            let g = color.greenComponent
            let b = color.blueComponent

            if r > 0.9 && g > 0.9 && b > 0.9 {
                bitmap.setColor(NSColor.clear, atX: x, y: y)
            } else {
                if x < minX { minX = x }
                if x > maxX { maxX = x }
                if y < minY { minY = y }
                if y > maxY { maxY = y }
            }
        }
    }

    // Crop image
    if minX > maxX || minY > maxY {
        minX = 0; minY = 0; maxX = width - 1; maxY = height - 1
    }
    
    let cropRect = NSRect(x: minX, y: height - maxY - 1, width: maxX - minX + 1, height: maxY - minY + 1)
    
    // Convert bitmap to cgimage
    guard let cgImage = bitmap.cgImage else { return }
    let cgCropRect = CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    
    guard let croppedCgImage = cgImage.cropping(to: cgCropRect) else { return }
    let croppedImage = NSImage(cgImage: croppedCgImage, size: NSSize(width: croppedCgImage.width, height: croppedCgImage.height))
    
    // Scale image
    let maxSize: CGFloat = 256.0
    let origSize = croppedImage.size
    let scale = min(maxSize / origSize.width, maxSize / origSize.height)
    let newSize = NSSize(width: origSize.width * scale, height: origSize.height * scale)
    
    let resizedImage = NSImage(size: newSize)
    resizedImage.lockFocus()
    NSGraphicsContext.current?.imageInterpolation = .high
    croppedImage.draw(in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: origSize), operation: .copy, fraction: 1.0)
    resizedImage.unlockFocus()
    
    // Save to file
    guard let finalTiff = resizedImage.tiffRepresentation,
          let finalBitmap = NSBitmapImageRep(data: finalTiff),
          let pngData = finalBitmap.representation(using: .png, properties: [:]) else {
        return
    }
    
    try? pngData.write(to: URL(fileURLWithPath: outPath))
}

let files = try! fm.contentsOfDirectory(atPath: srcDir)
let imageFiles = files.filter { $0.hasPrefix("kids_animals_") && $0.hasSuffix(".png") }

for file in imageFiles {
    // Extract base name, kids_animals_bear_1781911456371.png -> kids_animals_bear
    let components = file.components(separatedBy: "_")
    let baseName = components.dropLast().joined(separator: "_")
    
    let imagesetDir = destDir + "/\(baseName).imageset"
    try? fm.createDirectory(atPath: imagesetDir, withIntermediateDirectories: true, attributes: nil)
    
    let inPath = srcDir + "/" + file
    let outPath = imagesetDir + "/\(baseName).png"
    
    processImage(inPath, outPath: outPath)
    
    let json = """
{
  "images" : [
    {
      "filename" : "\(baseName).png",
      "idiom" : "universal",
      "scale" : "1x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""
    try? json.write(to: URL(fileURLWithPath: imagesetDir + "/Contents.json"), atomically: true, encoding: .utf8)
    print("Processed \(baseName)")
}
