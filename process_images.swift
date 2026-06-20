import AppKit
import Foundation

func makeWhiteTransparent(imagePath: String, outputPath: String) {
    guard let image = NSImage(contentsOfFile: imagePath),
          let tiffData = image.tiffRepresentation,
          let bitmapInfo = NSBitmapImageRep(data: tiffData) else {
        print("Could not load image at \(imagePath)")
        return
    }

    let width = bitmapInfo.pixelsWide
    let height = bitmapInfo.pixelsHigh

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width
    let bitsPerComponent = 8

    var pixelData = [UInt8](repeating: 0, count: width * height * 4)

    guard let context = CGContext(data: &pixelData,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: bitsPerComponent,
                                  bytesPerRow: bytesPerRow,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else {
        print("Failed to create context")
        return
    }

    guard let cgImage = bitmapInfo.cgImage else { return }
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    for i in stride(from: 0, to: pixelData.count, by: 4) {
        let r = pixelData[i]
        let g = pixelData[i+1]
        let b = pixelData[i+2]

        if r > 245 && g > 245 && b > 245 {
            pixelData[i] = 0
            pixelData[i+1] = 0
            pixelData[i+2] = 0
            pixelData[i+3] = 0
        }
    }

    guard let outCgImage = context.makeImage() else { return }
    let outRep = NSBitmapImageRep(cgImage: outCgImage)
    guard let outData = outRep.representation(using: .png, properties: [:]) else { return }

    do {
        try outData.write(to: URL(fileURLWithPath: outputPath))
        print("Saved to \(outputPath)")
    } catch {
        print("Failed to save: \(error)")
    }
}

makeWhiteTransparent(imagePath: CommandLine.arguments[1], outputPath: CommandLine.arguments[2])
