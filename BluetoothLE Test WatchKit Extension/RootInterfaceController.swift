//
//  RootInterfaceController.swift
//  BluetoothLE Test WatchKit Extension
//
//  Created by Collin Cunningham on 6/10/15.
//  Copyright (c) 2015 Adafruit Industries. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class RootInterfaceController: BLEInterfaceController, WCSessionDelegate {
    
    private var checkConnectionTimer:Timer?
    
//    static let sharedInstance = RootInterfaceController()
    
//    override func awakeWithContext(context: AnyObject?) {
//        super.awakeWithContext(context)
//    }

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        checkConnection()
        checkConnectionTimer = Timer(timeInterval: 5.0, target: self, selector: #selector(RootInterfaceController.checkConnection), userInfo: nil, repeats: true)
        checkConnectionTimer!.tolerance = 2.0
        RunLoop.current.add(checkConnectionTimer!, forMode: RunLoopMode.defaultRunLoopMode)
        
    }

    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        checkConnectionTimer?.invalidate()
        
    }
    
    
    func checkConnection(){
        
        sendRequest(message: ["type":"isConnected" as AnyObject])
        
    }
    
    @available(watchOSApplicationExtension 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    
}


class ControlPadInterfaceController: BLEInterfaceController {
    
    
    override func awake(withContext: Any?) {
        super.awake(withContext: withContext)
        
        // Configure interface objects here.
        
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    func buttonTapped(button:Int){
        
        //send button vals as dictionary
        let request = ["type":"sendData", "button":button] as [String:AnyObject]
        sendRequest(message: request)
//        WKInterfaceController.openParentApplication(request,
//            reply: { (replyInfo, error) -> Void in
//                // TODO: process reply data
//                NSLog("Reply: \(replyInfo)")
//        })
        
    }
    
    
    @IBAction func rightButtonTapped() {
        buttonTapped(button: 8)
    }
    
    
    @IBAction func leftButtonTapped() {
        buttonTapped(button: 7)
    }
    
    
    @IBAction func downButtonTapped() {
        buttonTapped(button: 6)
    }
    
    
    @IBAction func upButtonTapped() {
        buttonTapped(button: 5)
    }
    
    
    @IBAction func oneButtonTapped() {
        buttonTapped(button: 1)
    }
    
    
    @IBAction func twoButtonTapped() {
        buttonTapped(button: 2)
    }
    
    
    @IBAction func threeButtonTapped() {
        buttonTapped(button: 3)
    }
    
    
    @IBAction func fourButtonTapped() {
        buttonTapped(button: 4)
    }
}


class ColorPickerInterfaceController: BLEInterfaceController {
    
    @IBOutlet var rgbColorSwatch: WKInterfaceGroup?
    @IBOutlet var rSlider: WKInterfaceSlider?
    @IBOutlet var gSlider: WKInterfaceSlider?
    @IBOutlet var bSlider: WKInterfaceSlider?
    
    var rVal:UInt8 = 0
    var gVal:UInt8 = 0
    var bVal:UInt8 = 0
    
    var swatchColor = UIColor.gray
    var buttonColors:[UIColor] = [
        UIColor(red:0.969, green:0.400, blue:0.427, alpha:1.000),
        UIColor(red:0.992, green:0.694, blue:0.427, alpha:1.000),
        UIColor(red:1.000, green:1.000, blue:0.694, alpha:1.000),
        
        UIColor(red:1.000, green:0.000, blue:0.000, alpha:1.000),
        UIColor(red:1.000, green:0.502, blue:0.000, alpha:1.000),
        UIColor(red:1.000, green:1.000, blue:0.004, alpha:1.000),
        
        UIColor(red:0.686, green:0.000, blue:0.051, alpha:1.000),
        UIColor(red:0.686, green:0.184, blue:0.039, alpha:1.000),
        UIColor(red:0.667, green:0.714, blue:0.047, alpha:1.000),
        
        UIColor(red:0.706, green:1.000, blue:0.698, alpha:1.000),
        UIColor(red:0.706, green:1.000, blue:1.000, alpha:1.000),
        UIColor(red:0.500, green:0.500, blue:1.000, alpha:1.000),
        
        UIColor(red:0.000, green:1.000, blue:0.000, alpha:1.000),
        UIColor(red:0.004, green:1.000, blue:1.000, alpha:1.000),
        UIColor(red:0.000, green:0.000, blue:1.000, alpha:1.000),
        
        UIColor(red:0.137, green:0.718, blue:0.024, alpha:1.000),
        UIColor(red:0.122, green:0.702, blue:0.671, alpha:1.000),
        UIColor(red:0.000, green:0.000, blue:0.694, alpha:1.000),
        
        UIColor(red:0.847, green:0.682, blue:0.996, alpha:1.000),
        UIColor(red:0.992, green:0.678, blue:1.000, alpha:1.000),
        UIColor(red:1.000, green:1.000, blue:1.000, alpha:1.000),
        
        UIColor(red:0.518, green:0.000, blue:0.996, alpha:1.000),
        UIColor(red:0.984, green:0.000, blue:1.000, alpha:1.000),
        UIColor(red:0.502, green:0.502, blue:0.502, alpha:1.000),
        
        UIColor(red:0.271, green:0.000, blue:0.698, alpha:1.000),
        UIColor(red:0.682, green:0.000, blue:0.690, alpha:1.000),
        UIColor(red:0.000, green:0.000, blue:0.000, alpha:1.000)
    ]
    
    
    override func awake(withContext: Any?) {
        super.awake(withContext: withContext)
        
        // Configure interface objects here.
        
        //Set RGB color picker swatch color
        swatchColor = UIColor(red:CGFloat(0.75), green:CGFloat(0.25), blue:CGFloat(0.75), alpha:CGFloat(1.0))
        rgbColorSwatch?.setBackgroundColor(swatchColor)
        
        //retrieve rgb color vals from swatch
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        var blue:CGFloat = 0.0
        var alpha:CGFloat = 0.0
        swatchColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        //set slider vals
        rSlider?.setValue(Float(red))
        gSlider?.setValue(Float(green))
        bSlider?.setValue(Float(blue))
        
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    func setRGBColor(newColor:UIColor){
        
        swatchColor = newColor
        rgbColorSwatch?.setBackgroundColor(swatchColor)
        
    }
    
    
    func sendColor(color:UIColor){
        
        //send color vals as dictionary
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        var blue:CGFloat = 0.0
        var alpha:CGFloat = 0.0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let redInt = Int(Float(255)*Float(red))
        let blueInt = Int(Float(255)*Float(blue))
        let greenInt = Int(Float(255)*Float(green))
        let request = [ "type":"sendData",
                        "red":redInt,
                        "blue":blueInt,
                        "green":greenInt] as [String:AnyObject]
        
        sendRequest(message: request)
        
    }
    
    
    func colorTapped(index:Int) {
        
        //        println("color button tapped = \(index)")
        
        let color = buttonColors[index]
        
        sendColor(color: color)
    }
    
    
    @IBAction func rSliderChanged(value: Float) {
        
        //retrieve rgb color vals from swatch
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        var blue:CGFloat = 0.0
        var alpha:CGFloat = 0.0
        swatchColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let newColor = UIColor(red: CGFloat(value), green: green, blue: blue, alpha: 1.0)
        setRGBColor(newColor: newColor)
        
    }
    
    
    @IBAction func gSliderChanged(value: Float) {
        
        //retrieve rgb color vals from swatch
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        var blue:CGFloat = 0.0
        var alpha:CGFloat = 0.0
        swatchColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let newColor = UIColor(red: red, green: CGFloat(value), blue: blue, alpha: 1.0)
        setRGBColor(newColor: newColor)
        
    }
    
    
    @IBAction func bSliderChanged(value: Float) {
        
        //retrieve rgb color vals from swatch
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        var blue:CGFloat = 0.0
        var alpha:CGFloat = 0.0
        swatchColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let newColor = UIColor(red: red, green: green, blue: CGFloat(value), alpha: 1.0)
        setRGBColor(newColor: newColor)
        
    }
    
    
    @IBAction func sendButtonTapped() {
        
        //send color vals as dictionary
        sendColor(color: swatchColor)
        
    }
    
    
    @IBAction func color0Tapped() {
        colorTapped(index: 0)
    }
    
    
    @IBAction func color1Tapped() {
        colorTapped(index: 1)
    }
    
    
    @IBAction func color2Tapped() {
        colorTapped(index: 2)
    }
    
    
    @IBAction func color3Tapped() {
        colorTapped(index: 3)
    }
    
    
    @IBAction func color4Tapped() {
        colorTapped(index: 4)
    }
    
    
    @IBAction func color5Tapped() {
        colorTapped(index: 5)
    }
    
    
    @IBAction func color6Tapped() {
        colorTapped(index: 6)
    }
    
    
    @IBAction func color7Tapped() {
        colorTapped(index: 7)
    }
    
    
    @IBAction func color8Tapped() {
        colorTapped(index: 8)
    }
    
    
    @IBAction func color9Tapped() {
        colorTapped(index: 9)
    }
    
    
    @IBAction func color10Tapped() {
        colorTapped(index: 10)
    }
    
    
    @IBAction func color11Tapped() {
        colorTapped(index: 11)
    }
    
    
    @IBAction func color12Tapped() {
        colorTapped(index: 12)
    }
    
    
    @IBAction func color13Tapped() {
        colorTapped(index: 13)
    }
    
    
    @IBAction func color14Tapped() {
        colorTapped(index: 14)
    }
    
    
    @IBAction func color15Tapped() {
        colorTapped(index: 15)
    }
    
    
    @IBAction func color16Tapped() {
        colorTapped(index: 16)
    }
    
    
    @IBAction func color17Tapped() {
        colorTapped(index: 17)
    }
    
    
    @IBAction func color18Tapped() {
        colorTapped(index: 18)
    }
    
    
    @IBAction func color19Tapped() {
        colorTapped(index: 19)
    }
    
    
    @IBAction func color20Tapped() {
        colorTapped(index: 20)
    }
    
    
    @IBAction func color21Tapped() {
        colorTapped(index: 21)
    }
    
    
    @IBAction func color22Tapped() {
        colorTapped(index: 22)
    }
    
    
    @IBAction func color23Tapped() {
        colorTapped(index: 23)
    }
    
    
    @IBAction func color24Tapped() {
        colorTapped(index: 24)
    }
    
    
    @IBAction func color25Tapped() {
        colorTapped(index: 25)
    }
    
    
    @IBAction func color26Tapped() {
        colorTapped(index: 26)
    }


}
