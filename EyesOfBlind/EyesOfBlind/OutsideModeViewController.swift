//
//  OutsideModeViewController.swift
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/18.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//

import UIKit
import Speech

class OutsideModeViewController: UIViewController, FrameExtractorDelegate, SpeechToTextDelegate, UITextFieldDelegate {

    /****************************
     variables for voice control
     ***************************/
    
    private var txtToSpeech = TextToSpeech()
    private var voiceToText = SpeechToText()
    //use to store the command which is converted from voice
    private var voiceCommand = ""
    
    /*****************************
     variables for viewController
     ****************************/
    
    @IBOutlet var singleTap: UITapGestureRecognizer!
    private var canSingleTap = true
    
    /*************************************
     variables for camera frame extractor
     ************************************/
    
    private var viewExtractor = FrameExtractor()
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    /// all the unprocessed images from camera
    private var imageQueue = Queue<UIImage>()
    /// use to call the getImage function every time interval
    private var imageExtractTimer = Timer()
    /// unit is second which can be float number
    private var photoTimeInterval = 0.7
    
    /************************************
     variables for guiding tile function
     ***********************************/
    
    private var image1:UIImage? = nil
    private var threshold = 35.0
    private var alertTimer = Timer()
    private var alertSwitch = true
    
    /*****************************************
     change parameters to improve performance
     ****************************************/
    @IBOutlet weak var txtIn: UITextField!
    @IBOutlet weak var timeIn: UITextField!    
    
    @IBAction func getTime(_ sender: UIButton) {
        if let time = timeIn.text {
            photoTimeInterval = Double(time)!
        }
        timeIn.text = ""
    }
    
    @IBAction func getVal(_ sender: UIButton) {
        if let val = txtIn.text {
            threshold = Double(val)!
        }
        txtIn.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /*************************
     viewController functions
     ************************/
    
    override func viewWillAppear(_ animated: Bool) {
        txtToSpeech.say(txtIn: "in outside mode")
        viewExtractor.startRunningCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewExtractor.stopRunningCaptureSession()
        
        // invalidate the timer
        imageExtractTimer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        print("Receive Memory Warning")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // assign delegate to this class
        viewExtractor.delegate = self
        voiceToText.delegate = self
        txtIn.delegate = self
        timeIn.delegate = self
        /**
         ask authentication for speech recognition
         */
        voiceToText.authentication()
        
        // voice instruction for how to give voice command
        txtToSpeech.say(txtIn: "touch the screen and then start to say command, touch again when finishing speaking")
    }
    /**
     touch screen one time to call run function in SpeechToText class:
     first touch to activate the recording and then start to say command,
     second touch when finishing speaking
     */
    @IBAction func handleSingleTap(_ sender: UITapGestureRecognizer) {
        // diable single tap before command processing completed
        if canSingleTap {
            canSingleTap = voiceToText.run()
        }
    }
    
    /***********************
     SpeechToText functions
     ***********************/
    
    /**
     delegate function: get transcript from SpeechToText and process it
     */
    func returnTranscript(_ transcript: String) {
        voiceCommand = ""
        voiceCommand = transcript
        processCommand(command: self.voiceCommand)
        // enable single tap
        canSingleTap = true
    }
    /**
     decide what to do based on the receiving voice command
     */
    private func processCommand(command:String) {
        let commands = command.lowercased()
        
        if (commands == Commands.NaviMode) {
            self.tabBarController?.selectedIndex = 1
        }else if(commands == Commands.outsideMode){
            txtToSpeech.say(txtIn: "already in outside mode")
        }else if (commands == Commands.start) {
            /// start the guiding tiles functionality
            // re-activate the timer
            imageExtractTimer = Timer.scheduledTimer(timeInterval: photoTimeInterval, target: self, selector: #selector(OutsideModeViewController.getImage), userInfo: nil, repeats: true)
        }else if (commands == Commands.stop) {
            /// stop the guiding tiles functionality
            // invalidate the timer
            imageExtractTimer.invalidate()
        }else {
            txtToSpeech.say(txtIn: "no match command, say again")
        }
    }
    
    /*******************************************
     FrameExtractor and Guiding Tiles functions
     ******************************************/
    
    /**
     delegate function: show what camera see in the screen
     */
    func setupPreviewLayer(_ captureSession: AVCaptureSession?) {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    /**
     delegate function: get captured image from FrameExtractor
     */
    func returnImage(_ image: UIImage?) {
        imageQueue.enqueue(image!)
        if let image2 = imageQueue.dequeue() {
            if image1 == nil {
                image1 = image2
            }
//            let start = CACurrentMediaTime()
            let shift = OpenCVWrapper.positionShifting(image1!, andImage2: image2)
            
            /// guiding tiles function
            let blockTime = 2.0

            // > 0  means toward left; <0 means toward right
            if shift >= 0 {
                if abs(shift) >= threshold {
                    /*
                     once the alert emmitted, block emmitting for a time period
                     because a bunch images related to the same alert event
                     */
                    if alertSwitch {
                        txtToSpeech.say(txtIn: "toward right to keep straight")
                        alertSwitch = false
                        alertTimer = Timer.scheduledTimer(withTimeInterval: blockTime, repeats: false, block: { (alertTimer) in
                            self.turnOnAlert()
                        })
                    }
                }else {
                    // no need to change direction, therefore, change the base of comparision
                    image1 = image2
                }
            }else {
                if abs(shift) >= threshold {
                    if alertSwitch {
                        txtToSpeech.say(txtIn: "toward left to keep straight")
                        alertSwitch = false
                        alertTimer = Timer.scheduledTimer(withTimeInterval: blockTime, repeats: false, block: { (alertTimer) in
                            self.turnOnAlert()
                        })
                    }
                }else {
                    image1 = image2
                }
            }
//            let end = CACurrentMediaTime()
//            print("run time = \(end - start)")
        }else {
            print("get image2 from queue failed")
        }
    }
    
    @objc private func turnOnAlert() {
        alertSwitch = true
    }
    /**
     tell FrameExtractor class to capture image
     */
    @objc func getImage() {
        viewExtractor.captureImage()
    }
    
}
