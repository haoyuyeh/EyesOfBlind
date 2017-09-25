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
    
    // MARK: UITapGestureRecognizer
    @IBOutlet var singleTap: UITapGestureRecognizer!
    @IBOutlet var doubleTap: UITapGestureRecognizer!
    var canSingleTap = true

    override func viewWillAppear(_ animated: Bool) {
        txtToSpeech.say(txtIn: "in home mode")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // this will let singleTap not to perform when occurring double tap
        singleTap.require(toFail: doubleTap)
        
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
    @IBAction func handleSingleTap(_ sender: UITapGestureRecognizer) {
        // diable single tap before command processing completed
        if canSingleTap {
            canSingleTap = voiceToText.run()
        }
    }
    /*
     touch screen two times to call returnTranscript function in SpeechToText class:
     it will store the transcript of voice command in voiceCommand
     then process the command
     */
    @IBAction func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        voiceCommand = ""
        voiceCommand = voiceToText.returnTranscript()
        processCommand(command: self.voiceCommand)
        // enable single tap
        canSingleTap = true
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
    /*
     use to retrieve object name from find command
     */
    private func retrieveObject(sentence:String) -> String {
        // remove command and treat others as object
        let strs = sentence.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        return String(strs[1])
    }
}
