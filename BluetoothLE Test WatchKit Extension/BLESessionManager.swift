//
//  BLESessionManager.swift
//  Adafruit Bluefruit LE Connect
//
//  Created by Collin Cunningham on 11/3/15.
//  Copyright © 2015 Adafruit Industries. All rights reserved.
//

import Foundation
import WatchConnectivity

class BLESessionManager: NSObject, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    
    static let sharedInstance = BLESessionManager()
//    var session:WCSession?
    var deviceConnected:Bool = false
    
    
    override init(){
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
        }
        
    }
    
    
    func sendRequest(message:[String:AnyObject], sender:BLEInterfaceController) {
        
        sender.showDebugInfo(message: "attempting to send request")
        
        if WCSession.default().isReachable == false {
            sender.showDebugInfo(message: "WCSession is unreachable")
            return
        }
        
        WCSession.default().sendMessage(message,
            replyHandler: { (replyInfo) -> Void in
                switch (replyInfo["connected"] as? Bool) { //received correctly formatted reply
                case let connected where connected != nil:
                    if connected == true {  //app has connection to ble device
                        sender.showDebugInfo(message: "device connected")
                        sender.respondToConnected()
                        self.deviceConnected = true
                    }
                    else {  //app has NO connection to ble device
                        sender.showDebugInfo(message: "no device connected")
                        sender.respondToNotConnected()
                        self.deviceConnected = false
                    }
                default:
                    sender.showDebugInfo(message: "no connection info in reply")
                    sender.respondToNotConnected()
                    self.deviceConnected = false
                }
            },
            errorHandler: { (error) -> Void in
                sender.showDebugInfo(message: "\(error)") // received reply w error
        })
        
    }
    
    
}
