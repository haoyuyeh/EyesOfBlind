//
//  OutsideModeViewController.swift
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/18.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//

import UIKit
import Speech

class OutsideModeViewController: UIViewController {

    /*
     variables for voice control
     */
    private var txtToSpeech = TextToSpeech()
    private var voiceToText = SpeechToText()
    //use to store the command which is converted from voice
    private var voiceCommand = ""
    
    // MARK: UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        txtToSpeech.say(txtIn: "in outside mode")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        /*
         define two gestures for responding different tasks
         */
        let signleTap = UITapGestureRecognizer(target: self, action: #selector(OutsideModeViewController.handleSingleTap))
        signleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(signleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(OutsideModeViewController.handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
        // this will let singleTap not to perform when occurring double tap
        signleTap.require(toFail: doubleTap)
        // this will let the two functions beneath respond faster than touchesBegan()
        signleTap.delaysTouchesBegan = true
        doubleTap.delaysTouchesBegan = true
        
        /*
         ask authentication for speech recognition
         */
        voiceToText.authentication()
        // voice instruction for how to give voice command
        txtToSpeech.say(txtIn: "touch the screen and then start to say command, touch again when finishing speaking")
    }
    /*
     touch screen one time to call run function in SpeechToText class:
     first touch to activate the recording and then start to say command,
     second touch when finishing speaking
     */
    func handleSingleTap() {
        voiceToText.run()
    }
    /*
     touch screen two times to call returnTranscript function in SpeechToText class:
     it will store the transcript of voice command in voiceCommand
     */
    func handleDoubleTap() {
        voiceCommand = ""
        voiceCommand = voiceToText.returnTranscript()
//        print("voice command: \(self.voiceCommand)")
        processCommand(command: self.voiceCommand)
    }
    /*
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
}
