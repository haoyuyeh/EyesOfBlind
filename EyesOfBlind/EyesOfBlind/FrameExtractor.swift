//
//  FrameExtractor.swift
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/25.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//
import UIKit
import AVFoundation

class FrameExtractor: NSObject, AVCapturePhotoCaptureDelegate {
    /**
     */
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    var image = UIImage()
//    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override init() {
        super.init()
        setupCaptureSession()
        setupDevice()
        if #available(iOS 11.0, *) {
            setupInputOutput()
        } else {
            // Fallback on earlier versions
            print("only support iOS 11")
        }
    }
    
    /**
     */
    private func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.medium
    }
    /**
     */
    private func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            }else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        currentCamera = frontCamera
    }
    /**
     */
    @available(iOS 11.0, *)
    private func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch  {
            print(error)
        }
    }
    /**
     */
    func retrieveImage() -> UIImage {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
        return image
    }
//    func setupPreviewLayer() {
//        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//        cameraPreviewLayer?.frame = self.view.frame
//        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
//    }
    
    /**
     */
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    /**
     */
    func stopRunningCaptureSession() {
        captureSession.stopRunning()
    }
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            image = UIImage(data: imageData)!
        }
    }
}


