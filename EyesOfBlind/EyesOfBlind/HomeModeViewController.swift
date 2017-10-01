//
//  HomeModeViewController.swift
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/18.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//

import UIKit
import Speech

class HomeModeViewController: UIViewController, FrameExtractorDelegate, SpeechToTextDelegate {

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
    private let photoTimeInterval = 1.0
    
    /*************************
     viewController functions
     ************************/
    
    override func viewWillAppear(_ animated: Bool) {
        txtToSpeech.say(txtIn: "in home mode")
        
        viewExtractor.startRunningCaptureSession()
        
        // re-activate the timer
        imageExtractTimer = Timer.scheduledTimer(timeInterval: photoTimeInterval, target: self, selector: #selector(OutsideModeViewController.getImage), userInfo: nil, repeats: true)
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
        
        /*
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
        
        if (commands == Commands.outsideMode) {
            self.tabBarController?.selectedIndex = 0
        }else if(commands == Commands.homeMode){
            txtToSpeech.say(txtIn: "already in home mode")
        }else if(commands.starts(with: Commands.find)) {
            /*
             implement finding object code here
             */
            let object = retrieveObject(sentence: commands)
            print(object)
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
     use to retrieve object name from find command
     */
    private func retrieveObject(sentence:String) -> String {
        // remove command and treat others as object
        let strs = sentence.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        return String(strs[1])
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
