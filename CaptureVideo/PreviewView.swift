//
//  PreviewView.swift
//  CaptureVideo
//
//  Created by Tintash on 21/08/2019.
//  Copyright © 2019 Tintash. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {        
        return layer as! AVCaptureVideoPreviewLayer
    }
    
}
