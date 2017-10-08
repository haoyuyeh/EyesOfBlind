//
//  ToDoItemViewController.swift
//  EyesOfBlind
//
//  Created by Beth—荧 on 2017/10/7.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//

import Foundation
import UIKit

protocol ToDoItemDelegate {
    func didSaveItem(_ text : String, addressText: String)
}

class ToDoItemViewController: UIViewController,  UIBarPositioningDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var addressText: UITextField!
    
    @IBOutlet weak var text: UITextField!
    
    
    var delegate : ToDoItemDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //self.text.delegate = self
        self.addressText.delegate = self
        //self.text.becomeFirstResponder()
        //self.addressText.becomeFirstResponder()
    }
    
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        //self.text.resignFirstResponder()
        self.addressText.resignFirstResponder()
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        return true
    }
    
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        
        saveItem()
        //self.text.resignFirstResponder()
        self.addressText.resignFirstResponder()
        
    }
    
    // Textfield
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        saveItem()
        
        //textField.resignFirstResponder()
        return true
    }
    
    // Delegate
    
    func saveItem()
    {
        let texts = self.text.text
        let addressText = self.addressText.text
        self.delegate?.didSaveItem(texts!,addressText: addressText!)
        
    }
}

