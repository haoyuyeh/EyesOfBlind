//
//  HomeModeViewController.swift
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/18.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//

import UIKit
import Speech

class HomeModeViewController: UIViewController {

    /*
     variables for voice control
     */
    private var txtToSpeech = TextToSpeech()
    private var voiceToText = SpeechToText()
    //use to store the command which is converted from voice
    private var voiceCommand = ""
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        /*
         define two gestures for responding different tasks
         */
        let signleTap = UITapGestureRecognizer(target: self, action: #selector(HomeModeViewController.handleSingleTap))
        signleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(signleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(HomeModeViewController.handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
        // this will let singleTap not to perform when occurring double tap
        signleTap.require(toFail: doubleTap)
        // this will let the two functions beneath respond faster than touchesBegan()
        signleTap.delaysTouchesBegan = true
        doubleTap.delaysTouchesBegan = true
        
        // ask authentication for speech recognition
        voiceToText.authentication()
        // voice instruction for how to give voice command
        while true {
            if !TextToSpeech.synth.isSpeaking {
                txtToSpeech.say(txtIn: "in home mode")
                break
            }
        }
        while true {
            if !TextToSpeech.synth.isSpeaking {
                txtToSpeech.say(txtIn: "touch the screen and then start to say command, touch again when finishing speaking")
                break
            }
        }
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
        print("voice command: \(self.voiceCommand)")
    }
}
