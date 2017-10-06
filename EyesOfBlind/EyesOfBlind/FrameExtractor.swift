//
//  FrameExtractor.swift
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/25.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//
import UIKit
import AVFoundation

/**
 use this protocol to pass data to other class
 */
protocol FrameExtractorDelegate: class {
    // return the image captured by camera
    func returnImage(_ image: UIImage?)
    // show what camera see in the screen
    func setupPreviewLayer(_ captureSession : AVCaptureSession?)
}

class FrameExtractor: NSObject, AVCapturePhotoCaptureDelegate {
    /**
     */
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    var image = UIImage()
    weak var delegate: FrameExtractorDelegate?
    
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
    func captureImage() {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    /**
     */
    func startRunningCaptureSession() {
        /**
         setupPreviewLayer cannot be placed in init, because it will set up view layer,
         however, when viewController instanciate the object, the view still not be construct. therefore, it never be called.
         */
        delegate?.setupPreviewLayer(captureSession)
        captureSession.startRunning()
    }
    /**
     */
    func stopRunningCaptureSession() {
        captureSession.stopRunning()
    }
    
    /**
     get image data here 
     */
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            image = UIImage(data: imageData)!
            delegate?.returnImage(image)
        }
    }
}


