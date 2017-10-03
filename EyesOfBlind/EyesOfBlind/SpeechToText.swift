//
//  SpeechToText.swift
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/18.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//
/**
 This class "SpeechToText" is used to record voice and translate it to text form
 */

import UIKit
import Speech

/**
 use this protocol to pass data to other class
 */
protocol SpeechToTextDelegate: class {
    func returnTranscript(_ transcript: String)
}

public class SpeechToText:NSObject, SFSpeechRecognizerDelegate {
    
    /**
     SFSpeechRecognizer is the primary controller in the framework. Its most
     important job is to generate recognition tasks and return results. It also
     handles authorization and configures locales.
     */
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    /**
     SFSpeechRecognitionRequest is the base class for recognition requests.
     Its job is to point the SFSpeechRecognizer to an audio source from which
     transcription should occur. There are two concrete types: SFSpeechURLRecognitionRequest, for reading from a file, and SFSpeechAudioBufferRecognitionRequest for reading from a buffer.
     */
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    /**
     SFSpeechRecognitionTask objects are created when a request is kicked off
     by the recognizer. They are used to track progress of a transcription or
     cancel it.
     */
    private var recognitionTask: SFSpeechRecognitionTask?
    /**
     audioEngine is an AVAudioEngine object using to process input audio signals
     from the microphone.
     */
    private let audioEngine = AVAudioEngine()
    
    weak var delegate: SpeechToTextDelegate?
    
    var txtToSpeech = TextToSpeech()
    
    private var finalTranscript = ""
    
    /**
     confirm access to Speech recognition
     */
    func authentication(){
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("Speech recognition authenrized")
                
            case .denied:
                print("User denied access to speech recognition")
                
            case .restricted:
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                print("Speech recognition not yet authorized")
            }
        }
    }
    
    /**
     it's used to perform speech recognition and if completing the transcript,
     it will feedback with a voice instruction
     */
    private func startRecording() throws {
        finalTranscript = ""
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
        }
        
        // Configure request so that results are not returned before audio
        // recording is finished
        recognitionRequest.shouldReportPartialResults = false
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            
            var isFinal = false
            
            if let result = result {
                self.finalTranscript = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            // an error occurred or no coming audio input, stop corresponding components and
            // give a voice feedback
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.delegate?.returnTranscript(self.finalTranscript)

                // when ending the transcription, feedback with a voice instruction
//                if isFinal {
//                    self.delegate?.returnTranscript(self.finalTranscript)
//                }
            }
        }
        // adding audio input to recognitionRequest
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
    }
    
    /**
     stop the audioEngine and stop inputing audio
     */
    private func stopRecording(){
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }

    /**
     touch once to activate the recording and then start to say command,
     touch again when finishing speaking
     */
    func run() -> Bool{
        if audioEngine.isRunning {
            stopRecording()
            return false
        } else {
            do {
                try startRecording()
                self.txtToSpeech.say(txtIn: "start to say command")
                return true
            } catch  {
                print("fail to record\n")
                return true
            }
        }
    }
}

