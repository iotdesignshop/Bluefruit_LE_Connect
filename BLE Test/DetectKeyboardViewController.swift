//
//  AutoScrollOnKeyboardViewController.swift
//  Adafruit Bluefruit LE Connect
//
//  Created by Antonio García on 30/07/15.
//  Copyright (c) 2015 Adafruit Industries. All rights reserved.
//

import UIKit

class KeyboardAwareViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerKeyboardNotifications(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        registerKeyboardNotifications(false)
    }
    
    func registerKeyboardNotifications(_ enable : Bool) {
        let notificationCenter = NotificationCenter.default
        if (enable) {
            notificationCenter.addObserver(self, selector: "keyboardWillBeShown:", name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            notificationCenter.addObserver(self, selector: "keyboardWillBeHidden:", name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        } else {
            notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
    }
    
    func keyboardWillBeShown(_ notification : Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue
       
        keyboardPositionChanged(keyboardFrame, keyboardShown: true)
    }
    
    func keyboardWillBeHidden(_ notification : Notification) {
       keyboardPositionChanged(CGRect.zero, keyboardShown: false)
    }
    
    func keyboardPositionChanged(_ keyboardFrame : CGRect, keyboardShown : Bool) {
        // to be implemented by subclass
    }
}
