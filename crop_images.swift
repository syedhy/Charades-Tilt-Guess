import AppKit
import Foundation
import CoreGraphics

func cropToNonTransparent(imagePath: String, outputPath: String) {
    guard let image = NSImage(contentsOfFile: imagePath),
          let tiffData = image.tiffRepresentation,
          let bitmapInfo = NSBitmapImageRep(data: tiffData),
          let cgImage = bitmapInfo.cgImage else {
        print("Could not load image at \(imagePath)")
        return
    }

    let width = bitmapInfo.pixelsWide
    let height = bitmapInfo.pixelsHigh
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width

    var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
    guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else { return }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    var minX = width
    var maxX = 0
    var minY = height
    var maxY = 0

    for y in 0..<height {
        for x in 0..<width {
            let offset = (y * width + x) * bytesPerPixel
            let alpha = pixelData[offset + 3]
            if alpha > 0 {
                if x < minX { minX = x }
                if x > maxX { maxX = x }
                if y < minY { minY = y }
                if y > maxY { maxY = y }
            }
        }
    }

    if minX > maxX || minY > maxY {
        print("Image is entirely transparent")
        return
    }

    let cropRect = CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    guard let croppedCgImage = cgImage.cropping(to: cropRect) else { return }

    let outRep = NSBitmapImageRep(cgImage: croppedCgImage)
    guard let outData = outRep.representation(using: .png, properties: [:]) else { return }

    do {
        try outData.write(to: URL(fileURLWithPath: outputPath))
        print("Saved cropped image to \(outputPath)")
    } catch {
        print("Failed to save: \(error)")
    }
}

cropToNonTransparent(imagePath: CommandLine.arguments[1], outputPath: CommandLine.arguments[2])
