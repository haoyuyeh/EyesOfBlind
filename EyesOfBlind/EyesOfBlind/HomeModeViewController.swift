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
    
    override func viewWillAppear(_ animated: Bool) {
        txtToSpeech.say(txtIn: "in home mode")
    }
    
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
        txtToSpeech.say(txtIn: "touch the screen and then start to say command, touch again when finishing speaking")
    }
    /*
     touch screen one time to call run function in SpeechToText class:
     first touch to activate the recording and then start to say command,
     second touch when finishing speaking
     */
    @objc func handleSingleTap() {
        voiceToText.run()
    }
    /*
     touch screen two times to call returnTranscript function in SpeechToText class:
     it will store the transcript of voice command in voiceCommand
     */
    @objc func handleDoubleTap() {
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
        
        if (commands == Commands.outsideMode) {
            self.tabBarController?.selectedIndex = 0
        }else if(commands == Commands.homeMode){
            txtToSpeech.say(txtIn: "already in home mode")
        }else if(startWith(sentence: commands, word: Commands.find)) {
            /*
             implement finding object code here
             */
            let object = retrieveObject(sentence: commands)
            print(object)
        }else {
            txtToSpeech.say(txtIn: "no match command, say again")
        }
    }
    /*
    determine whether the input sentence starts with the input word
    if yes, return true
     */
    private func startWith(sentence:String, word:String) -> Bool {
        let sentenceSplit = sentence.components(separatedBy: " ")
        if(sentenceSplit[0] == word) {
            return true
        }else {
            return false
        }
    }
    /*
     use to retrieve object name from find command
     */
    private func retrieveObject(sentence:String) -> String {
        // +1 for removing space
        let index = Commands.find.characters.count + 1
        let startIndex = sentence.index(sentence.startIndex, offsetBy: index)
        return sentence.substring(from: startIndex)
    }
}
