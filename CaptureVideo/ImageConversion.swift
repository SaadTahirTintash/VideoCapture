//
//  ImageConversion.swift
//  CaptureVideo
//
//  Created by Tintash on 23/08/2019.
//  Copyright © 2019 Tintash. All rights reserved.
//

import Foundation
import UIKit

struct PixelData {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

protocol ImageConversion {}

extension ImageConversion {
    
    func convertImage(pixels: [PixelData], image: UIImage) -> UIImage? {
        
        //Converting the pixel RGBA data back to uiimage
        let imageWidth = Int(image.size.width)
        let imageHeight = Int(image.size.height)
        guard let image = imageFromARGB32Bitmap(pixels: pixels, width: imageWidth, height: imageHeight) else { return nil}
        
        return image
        
    }
    
    private func imageFromARGB32Bitmap(pixels: [PixelData], width: Int, height: Int) -> UIImage? {
        guard width > 0 && height > 0 else { return nil }
        guard pixels.count == width * height else { return nil }
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        let bytesPerRow = width * MemoryLayout<PixelData>.size
        
        var data = pixels // Copy to mutable []
        guard let providerRef = CGDataProvider(data: NSData(bytes: &data,
                                                            length: data.count * MemoryLayout<PixelData>.size)
            )
            else { return nil }
        
        guard let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
            )
            else { return nil }
        
        return UIImage(cgImage: cgim)
    }
    
}
