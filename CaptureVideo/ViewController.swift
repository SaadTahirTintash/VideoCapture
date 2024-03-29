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

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var captureButton: UIButton!
    
    var captureSession : AVCaptureSession!
    var videoDataOutput: AVCaptureVideoDataOutput!
    var movieOutput = AVCaptureMovieFileOutput()
    var isVideoRunning : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
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
            
            //add input/output devices
            if captureSession.canAddInput(videoDeviceInput), captureSession.canAddOutput(videoDataOutput) {
                captureSession.addInput(videoDeviceInput)
                captureSession.addOutput(videoDataOutput)
                captureSession.addOutput(movieOutput)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
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
            captureButton.backgroundColor = .white
        } else {
            movieOutput.stopRecording()
            print("Recording Stopped")
            captureButton.backgroundColor = .red
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            print(error?.localizedDescription ?? "ERROR")
            return
        }
        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        print("Recording Saved to Gallery")
    }

}

