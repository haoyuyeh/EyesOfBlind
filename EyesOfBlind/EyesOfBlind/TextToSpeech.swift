//
//  TextToSpeech.swift
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/18.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//
/**
 This class "TextToSpeech" is used to transform a text into voice
 */
import Foundation
import AVFoundation

class TextToSpeech {
    static let synth = AVSpeechSynthesizer()
    
    func say(txtIn:String) {
        let utterance = AVSpeechUtterance(string: txtIn)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        // make sure that the sentence would be spoken
        while true {
            if(!TextToSpeech.synth.isSpeaking) {
                TextToSpeech.synth.speak(utterance)
                break
            }
        }
        
    }
}
