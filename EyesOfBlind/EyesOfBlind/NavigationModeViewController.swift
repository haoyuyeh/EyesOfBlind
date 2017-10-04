//
//  HomeModeViewController.swift
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/18.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//

import UIKit
import Speech

class NavigationModeViewController: UIViewController, SpeechToTextDelegate {

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
    
    /*************************
     viewController functions
     ************************/
    
    override func viewWillAppear(_ animated: Bool) {
        txtToSpeech.say(txtIn: "in navigation mode")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // assign delegate to this class
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
        }else if(commands == Commands.NaviMode){
            txtToSpeech.say(txtIn: "already in navigation mode")
        }else if(commands.starts(with: Commands.find)) {
            
        }else {
            txtToSpeech.say(txtIn: "no match command, say again")
        }
    }
}
