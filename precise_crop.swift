import AppKit
import Foundation

func cropToContent(imagePath: String, outputPath: String) {
    guard let image = NSImage(contentsOfFile: imagePath),
          let tiffData = image.tiffRepresentation,
          let bitmapInfo = NSBitmapImageRep(data: tiffData),
          let cgImage = bitmapInfo.cgImage else {
        return
    }

    let width = bitmapInfo.pixelsWide
    let height = bitmapInfo.pixelsHigh
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width

    var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else { return }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    var minX = width
    var maxX = 0
    var minY = height
    var maxY = 0

    for y in 0..<height {
        for x in 0..<width {
            let offset = (y * width + x) * bytesPerPixel
            let r = pixelData[offset]
            let g = pixelData[offset+1]
            let b = pixelData[offset+2]
            let a = pixelData[offset+3]

            // Check if pixel is NOT effectively white or transparent
            let isTransparent = (a == 0)
            let isWhite = (r > 230 && g > 230 && b > 230)

            if !isTransparent && !isWhite {
                if x < minX { minX = x }
                if x > maxX { maxX = x }
                if y < minY { minY = y }
                if y > maxY { maxY = y }
            }
        }
    }

    print("New bounding box for \(imagePath): \(minX), \(minY), \(maxX), \(maxY)")

    // Add a tiny bit of padding
    minX = max(0, minX - 10)
    minY = max(0, minY - 10)
    maxX = min(width - 1, maxX + 10)
    maxY = min(height - 1, maxY + 10)

    let cropRect = CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    guard let croppedCgImage = cgImage.cropping(to: cropRect) else { return }

    let outRep = NSBitmapImageRep(cgImage: croppedCgImage)
    guard let outData = outRep.representation(using: .png, properties: [:]) else { return }

    try? outData.write(to: URL(fileURLWithPath: outputPath))
    print("Saved to \(outputPath)")
}

cropToContent(imagePath: CommandLine.arguments[1], outputPath: CommandLine.arguments[2])
