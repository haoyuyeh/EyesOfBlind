//
//  OutsideModeViewController.swift
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/18.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//

import UIKit
import Speech

class OutsideModeViewController: UIViewController, FrameExtractorDelegate, SpeechToTextDelegate {

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
    var canSingleTap = true
    
    /************************************
     variable for camera frame extractor
     ***********************************/
    
    private var viewExtractor = FrameExtractor()
    /// all the unprocessed images from camera
    var imageQueue = Queue<UIImage>()
    /// use to call the getImage function every time interval
    private var imageExtractTimer = Timer()
    /// unit is second which can be float number
    private let photoTimeInterval = 0.6
    
    /************************************
     testing code will be removed later
     ***********************************/
    
    @IBOutlet weak var previousImage: UIImageView!
    
    @IBAction func takePictures(_ sender: UIButton) {
        getImage()
    }
    
    @IBAction func processingImages(_ sender: UIButton) {
        if let image1 = imageQueue.dequeue() {
            if let image2 = imageQueue.dequeue() {
                let start = CACurrentMediaTime()
                previousImage.image = OpenCVWrapper.imageSimilarity(image1, andImage2: image2)
                let end = CACurrentMediaTime()
                print("run time = \(end - start)")
            }else {
                // get second failed, therefore, put image1 back to the queue
                imageQueue.enqueue(image1)
                print("get image2 from queue failed")
            }
        }else {
            print("get image1 from queue failed")
        }
        print("num of stored images: \(imageQueue.count)")
    }
    
    /*************************
     viewController functions
     ************************/
    
    override func viewWillAppear(_ animated: Bool) {
        txtToSpeech.say(txtIn: "in outside mode")
        
        viewExtractor.startRunningCaptureSession()
        
        // re-activate the timer
//        imageExtractTimer = Timer.scheduledTimer(timeInterval: photoTimeInterval, target: self, selector: #selector(OutsideModeViewController.getImage), userInfo: nil, repeats: true)
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
        // assign delegate of viewExtractor and voiceToText to this class
        viewExtractor.delegate = self
        voiceToText.delegate = self
        
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
        print(voiceCommand)
        processCommand(command: self.voiceCommand)
        // enable single tap
        canSingleTap = true
    }
    /**
     decide what to do based on the receiving voice command
     */
    private func processCommand(command:String) {
        let commands = command.lowercased()
        
        if (commands == Commands.homeMode) {
            self.tabBarController?.selectedIndex = 1
        }else if(commands == Commands.outsideMode){
            txtToSpeech.say(txtIn: "already in outside mode")
        }else {
            txtToSpeech.say(txtIn: "no match command, say again")
        }
    }
    
    /*************************
     FrameExtractor functions
     ************************/
    
    /**
     delegate function: get captured image from FrameExtractor
     */
    func returnImage(_ image: UIImage?) {
        imageQueue.enqueue(image!)
        print("num of stored images: \(imageQueue.count)")
    }
    
    /**
     tell FrameExtractor class to capture image
     */
    @objc func getImage() {
        viewExtractor.captureImage()
    }
    
    /***********************
     OpenCV functions
     ***********************/
}
