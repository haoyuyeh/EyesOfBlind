//
//  Commands.swift
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/18.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//
/**
 This class is used to record all voice commands in every modes
 The charactors of commnad should all be lowercase; 
 if there are more than two words in a command, it should add a space between words.
 example: "go to outside mode"
 */
import Foundation

class Commands {
    /// change to outside mode
    static let outsideMode = "outside mode"
    // start the guiding tiles function
    static let start = "start"
    // stop the guiding tiles function
    static let stop = "stop"
    /// change to home mode
    static let NaviMode = "navigation"
    /// find object under home mode
    static let find = "begin"
    
    
    
}
