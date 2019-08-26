//
//  Extensions.swift
//  CaptureVideo
//
//  Created by Tintash on 21/08/2019.
//  Copyright © 2019 Tintash. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func getPixelData(data: UnsafePointer<UInt8>, pos: CGPoint) -> PixelData {
        
        let pixelInfo : Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = data[pixelInfo]
        let g = data[pixelInfo+1]
        let b = data[pixelInfo+2]
        let a = data[pixelInfo+3]
        
        return PixelData(a: a, r: r, g: g, b: b)
    }
    
    func getPixelDataArray() -> [PixelData]{
        let pixelsWide = Int(self.size.width)
        let pixelsHigh = Int(self.size.height)
        
        guard let pixelData = self.cgImage?.dataProvider?.data else { return [] }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var imageColors: [PixelData] = []
        for x in 0..<pixelsWide {
            for y in 0..<pixelsHigh {
                let cgPoint = CGPoint(x: x, y: y)
                let color = self.getPixelData(data: data, pos: cgPoint)
                imageColors.append(color)
            }
        }
        return imageColors
    }
    
    func getPixelData2DArray() -> [[PixelData]]{
        let pixelsWide = Int(self.size.width)
        let pixelsHigh = Int(self.size.height)
        
        guard let pixelData = self.cgImage?.dataProvider?.data else { return [] }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var imageColors: [[PixelData]] = []        
        for x in 0..<pixelsWide {
            imageColors.append([PixelData]())
            for y in 0..<pixelsHigh {
                let cgPoint = CGPoint(x: x, y: y)
                let color = self.getPixelData(data: data, pos: cgPoint)
                imageColors[x].append(color)
            }
        }
        return imageColors
    }
}
