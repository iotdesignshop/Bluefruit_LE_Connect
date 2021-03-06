//
//  BLEInterfaceController.swift
//  Adafruit Bluefruit LE Connect
//
//  Created by Collin Cunningham on 6/27/15.
//  Copyright (c) 2015 Adafruit Industries. All rights reserved.
//

import WatchKit
import Foundation

class BLEInterfaceController: WKInterfaceController {
    
    
    @IBOutlet weak var noConnectionLabel: WKInterfaceLabel?
    @IBOutlet weak var controllerModeGroup: WKInterfaceGroup?
    @IBOutlet weak var debugLabel: WKInterfaceLabel?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.addMenuItem(with: WKMenuItemIcon.decline, title: "Disconnect", action: #selector(BLEInterfaceController.disconnectButtonTapped))
        
    }
    
    
    func disconnectButtonTapped() {
        
        sendRequest(message: ["type":"command" as AnyObject, "command":"disconnect" as AnyObject])
        
    }

    
    func sendRequest(message:[String:AnyObject]){
        
        BLESessionManager.sharedInstance.sendRequest(message: message, sender: self)
        
    }
    
    
    func respondToConnected() {
        
        self.noConnectionLabel?.setHidden(true)
        self.controllerModeGroup?.setHidden(false)
        
    }
    
    
    func respondToNotConnected() {
        
        self.noConnectionLabel?.setHidden(false)
        self.controllerModeGroup?.setHidden(true)
        
        WKInterfaceController.reloadRootControllers(withNames: ["Root"], contexts: nil)
        
    }
    
    
    func showDebugInfo(message:String) {
        
        self.debugLabel?.setText(message)
        
    }
    
    
        //OLD METHOD
//        WKInterfaceController.openParentApplication(request,
//            reply: { (replyInfo, error) -> Void in
//                //parse reply info
//                switch (replyInfo["connected"] as? Bool, error) { //received correctly formatted reply
//                case let (connected, nil) where connected != nil:
//                    if connected == true {  //app has connection to ble device
////                        NSLog("reply received == connected")
//                        self.respondToConnected()
//                    }
//                    else {  //app has NO connection to ble device
////                        NSLog("reply received == not connected")
//                        self.respondToNotConnected()
//                    }
//                case let (_, .Some(error)):
//                    print("reply received with error: \(error)") // received reply w error
//                default:
//                    print("reply received with no error or data ...") // received reply with no data or error
//                }
//        })
        
//    }
    
}
