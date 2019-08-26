//
//  ViewController.swift
//  CaptureVideo
//
//  Created by Tintash on 21/08/2019.
//  Copyright © 2019 Tintash. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

//For a simple camera capturing application, you need a CaptureSession, atleast one input and atleast one output device. To show what the user is seeing, we need a PreviewLayer

class ViewController: UIViewController, ImageConversion {
    
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var convertedImage: UIImageView!
    @IBOutlet weak var videoPreviewImage: UIImageView!
    
    var captureSession : AVCaptureSession!
    var videoDataOutput: AVCaptureVideoDataOutput!
    var movieOutput = AVCaptureMovieFileOutput()
    var isVideoRunning : Bool = false
    var currentSnapPixelData = [PixelData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        testStillImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    func testStillImage() {
        //original image
        let image = UIImage(named: "pehlinazar")//?.rotate(radians: -.pi/2)
        let originalImagePixelData = image?.getPixelDataArray()
        videoPreviewImage.image = image
        
        //convertedImage
        let convertedImg = convertImage(pixels: originalImagePixelData!, image: image!)
        _ = convertedImg?.getPixelDataArray()
        convertedImage.image = convertedImg
    }
    
    @IBAction func takeSnapshot(_ sender: UIButton) {
        
    }
    
    func createCaptureSession() {
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .low
        
        //begin capture session
        captureSession.beginConfiguration()
        
        //configure input device
        guard let videoDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: .unspecified) else {
            print("Unable to access back camera!")
            return
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            //configure Output device
            videoDataOutput = AVCaptureVideoDataOutput()
//            videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) as String: kCMPixelFormat_32BGRA]
            
            
            
            let sampleBufferQueue = DispatchQueue(label: "sample buffer")
            videoDataOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
            
            //add input/output devices
            if captureSession.canAddInput(videoDeviceInput), captureSession.canAddOutput(videoDataOutput) {
                captureSession.addInput(videoDeviceInput)
                captureSession.addOutput(videoDataOutput)
                //Recording and Frame capturing doesn't work together. Only 1 of them can work at a time
                //                captureSession.addOutput(movieOutput)
                //add preview layer
                setupLivePreview()
            }
            
        } catch let error {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
        //save and complete capture session
        captureSession.commitConfiguration()
        
        captureSession.startRunning()
    }
    
    func setupLivePreview() {
        previewView.videoPreviewLayer.session = captureSession
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        previewView.videoPreviewLayer.connection?.videoOrientation = .portrait
    }
    
    @IBAction func didTapToRecord(_ sender: UIButton) {
        
        isVideoRunning = !isVideoRunning
        
        if isVideoRunning {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileUrl = paths[0].appendingPathComponent("output.mov")
            try? FileManager.default.removeItem(at: fileUrl)
            
            movieOutput.startRecording(to: fileUrl, recordingDelegate: self)
            print("Recording Started")
        } else {
            movieOutput.stopRecording()
            print("Recording Stopped")
        }
    }
}

extension ViewController : AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            print(error?.localizedDescription ?? "ERROR")
            return
        }
        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        print("Recording Saved to Gallery")
    }

}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to converted to imageBuffer")
            return nil
        }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        
        let context = CIContext()
//        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent, format: CIFormat.BGRA8, colorSpace: CGColorSpaceCreateDeviceRGB()) else {
//            print("Failed to create cgImage")
//            return nil
//        }
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("Failed to create cgImage")
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        guard let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        //Converting image to pixel RGBA data
        let pixelArray = image.getPixelDataArray()
        
        DispatchQueue.main.async { [weak self] in
            self?.videoPreviewImage.image = image
        }
    }
    
    
}


