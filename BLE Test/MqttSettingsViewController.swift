//
//  MqttSettingsViewController.swift
//  Adafruit Bluefruit LE Connect
//
//  Created by Antonio García on 28/07/15.
//  Copyright (c) 2015 Adafruit Industries. All rights reserved.
//

import UIKit


class MqttSettingsViewController: KeyboardAwareViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MqttManagerDelegate {
    // Constants
    fileprivate static let defaultHeaderCellHeight : CGFloat = 50;
    
    // UI
    @IBOutlet weak var baseTableView: UITableView!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var pickerToolbar: UIToolbar!
    
    // Data
    fileprivate enum SettingsSections : Int {
        case status = 0
        case server = 1
        case publish = 2
        case subscribe = 3
        case advanced = 4
    }
    
    fileprivate enum PickerViewType {
        case qos
        case action
    }
    
    fileprivate var selectedIndexPath = IndexPath(row: 0, section: 0)
    fileprivate var pickerViewType = PickerViewType.qos
    fileprivate var previousSubscriptionTopic : String?
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "MQTT Settings"
        
        // Register custom cell nibs
        baseTableView.register(UINib(nibName: "MqttSettingsHeaderCell", bundle: nil), forCellReuseIdentifier: "HeaderCell")
        baseTableView.register(UINib(nibName: "MqttSettingsStatusCell", bundle: nil), forCellReuseIdentifier: "StatusCell")
        baseTableView.register(UINib(nibName: "MqttSettingsEditValueCell", bundle: nil), forCellReuseIdentifier: "EditValueCell")
        baseTableView.register(UINib(nibName: "MqttSettingsEditValuePickerCell", bundle: nil), forCellReuseIdentifier: "EditValuePickerCell")
        baseTableView.register(UINib(nibName: "MqttSettingsEditPickerCell", bundle: nil), forCellReuseIdentifier: "EditPickerCell")
        
        // Note: baseTableView is grouped to make the section titles no to overlap the section rows
        baseTableView.backgroundColor = UIColor.clear
        
        previousSubscriptionTopic = MqttSettings.sharedInstance.subscribeTopic
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        MqttManager.sharedInstance.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (IS_IPAD) {
            self.view.endEditing(true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func headerTitleForSection(_ section: Int) -> String? {
        switch(section) {
        case SettingsSections.status.rawValue: return nil
        case SettingsSections.server.rawValue: return "Server"
        case SettingsSections.publish.rawValue: return "Publish"
        case SettingsSections.subscribe.rawValue: return "Subscribe"
        case SettingsSections.advanced.rawValue: return "Advanced"
        default: return nil
        }
    }

    func subscriptionTopicChanged(_ newTopic: String?, qos: MqttManager.MqttQos) {
        printLog(self, funcName: (#function), logString: "subscription changed from: \(previousSubscriptionTopic) to: \(newTopic)");
        
        let mqttManager = MqttManager.sharedInstance
        if (previousSubscriptionTopic != nil) {
            mqttManager.unsubscribe(previousSubscriptionTopic!)
        }
        if (newTopic != nil) {
            mqttManager.subscribe(newTopic!, qos: qos)
        }
        previousSubscriptionTopic = newTopic
    }
    
    func indexPathFromTag(_ tag: Int) -> IndexPath {
        // To help identify each textfield a tag is added with this format: 12 (1 is the section, 2 is the row)
        return IndexPath(row: tag % 10, section: tag / 10)
    }
    
    func tagFromIndexPath(_ indexPath : IndexPath) -> Int {
        // To help identify each textfield a tag is added with this format: 12 (1 is the section, 2 is the row)
        return indexPath.section * 10 + indexPath.row
    }
    
    // MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSections.advanced.rawValue + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case SettingsSections.status.rawValue: return 1
        case SettingsSections.server.rawValue: return 2
        case SettingsSections.publish.rawValue: return 2
        case SettingsSections.subscribe.rawValue: return 2
        case SettingsSections.advanced.rawValue: return 2
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let section = indexPath.section
        let row = indexPath.row;
        
        let cell : UITableViewCell
        
        if(section == SettingsSections.status.rawValue) {
            
            let statusCell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath) as! MqttSettingsStatusCell
            
            let status = MqttManager.sharedInstance.status
            let showWait = status == .connecting || status == .disconnecting
            if (showWait) {
                statusCell.waitView.startAnimating()
            }else {
                statusCell.waitView.stopAnimating()
            }
            statusCell.actionButton.isHidden = showWait
            
            let statusText : String;
            switch(status) {
            case .connected: statusText = "Connected"
            case .connecting: statusText = "Connecting..."
            case .disconnecting: statusText = "Disconnecting..."
            case .error: statusText = "Error"
            default: statusText = "Disconnected"
            }
            
            statusCell.statusLabel.text = statusText
            
            UIView.performWithoutAnimation({ () -> Void in      // Change title disabling animations (if enabled the user can see the old title for a moment)
                statusCell.actionButton.setTitle(status == .connected ?"Disconnect":"Connect", for: UIControlState())
                statusCell.layoutIfNeeded()
            })

            statusCell.onClickAction = {
                [unowned self] in

                // End editing
                self.view.endEditing(true)
                
                // Connect / Disconnect
                let mqttManager = MqttManager.sharedInstance
                let status = mqttManager.status
                if (status == .disconnected || status == .none || status == .error) {
                    mqttManager.connectFromSavedSettings()
                } else {
                    mqttManager.disconnect()
                    MqttSettings.sharedInstance.isConnected = false
                }
                
                self.baseTableView?.reloadData()
            }
            
            cell = statusCell
        }
        else {
            let mqttSettings = MqttSettings.sharedInstance
            let editValueCell : MqttSettingsEditValueCell
            
            switch(section) {
            case SettingsSections.server.rawValue:
                editValueCell = tableView.dequeueReusableCell(withIdentifier: "EditValueCell", for: indexPath) as! MqttSettingsEditValueCell
                editValueCell.reset()
                
                let labels = ["Address:", "Port:"]
                editValueCell.nameLabel.text = labels[row]
                let valueTextField = editValueCell.valueTextField!      // valueTextField should exist on this cell
                if (row == 0) {
                    valueTextField.text = mqttSettings.serverAddress
                }
                else if (row == 1) {
                    valueTextField.placeholder = "\(MqttSettings.defaultServerPort)"
                    if (mqttSettings.serverPort != MqttSettings.defaultServerPort) {
                        valueTextField.text = "\(mqttSettings.serverPort)"
                    }
                    valueTextField.keyboardType = UIKeyboardType.numberPad;
                }

            case SettingsSections.publish.rawValue:
                editValueCell = tableView.dequeueReusableCell(withIdentifier: "EditValuePickerCell", for: indexPath) as! MqttSettingsEditValueCell
                editValueCell.reset()

                let labels = ["UART RX:", "UART TX:"]
                editValueCell.nameLabel.text = labels[row]
                
                let valueTextField = editValueCell.valueTextField!
                valueTextField.text = mqttSettings.getPublishTopic(row)
                
                let typeTextField = editValueCell.typeTextField!
                typeTextField.text = titleForQos(mqttSettings.getPublishQos(row))
                setupTextFieldForPickerInput(typeTextField, indexPath: indexPath)
                
            case SettingsSections.subscribe.rawValue:
                editValueCell = tableView.dequeueReusableCell(withIdentifier: row==0 ? "EditValuePickerCell":"EditPickerCell", for: indexPath) as! MqttSettingsEditValueCell
                editValueCell.reset()
                
                let labels = ["Topic:", "Action:"]
                editValueCell.nameLabel.text = labels[row]
                
                let typeTextField = editValueCell.typeTextField!
                if (row == 0) {
                    let valueTextField = editValueCell.valueTextField!
                    valueTextField.text = mqttSettings.subscribeTopic

                    typeTextField.text = titleForQos(mqttSettings.subscribeQos)
                    setupTextFieldForPickerInput(typeTextField, indexPath: indexPath)
                }
                else if (row == 1) {
                    typeTextField.text = titleForSubscribeBehaviour(mqttSettings.subscribeBehaviour)
                    setupTextFieldForPickerInput(typeTextField, indexPath: indexPath)
                }

            case SettingsSections.advanced.rawValue:
                editValueCell = tableView.dequeueReusableCell(withIdentifier: "EditValueCell", for: indexPath) as! MqttSettingsEditValueCell
                editValueCell.reset()

                let labels = ["Username:", "Password:"]
                editValueCell.nameLabel.text = labels[row]
                
                let valueTextField = editValueCell.valueTextField!
                if (row == 0) {
                    valueTextField.text = mqttSettings.username
                }
                else if (row == 1) {
                    valueTextField.text = mqttSettings.password
                }

            default:
                editValueCell = tableView.dequeueReusableCell(withIdentifier: "EditValueCell", for: indexPath) as! MqttSettingsEditValueCell
                editValueCell.reset()
                
                break;
            }

            if let valueTextField = editValueCell.valueTextField {
                valueTextField.returnKeyType = UIReturnKeyType.next
                valueTextField.delegate = self;
                valueTextField.tag = tagFromIndexPath(indexPath)
            }

            cell = editValueCell
        }

        return cell
    }
    
    func setupTextFieldForPickerInput(_ textField : UITextField, indexPath : IndexPath) {
        textField.inputView = pickerView
        textField.inputAccessoryView = pickerToolbar
        textField.delegate = self
        textField.tag = tagFromIndexPath(indexPath);
        textField.textColor = self.view.tintColor
        textField.tintColor = UIColor.clear  // remove caret
    }
    
    func titleForSubscribeBehaviour(_ behaviour: MqttSettings.SubscribeBehaviour) -> String {
        switch(behaviour) {
        case .localOnly: return "Local Only"
        case .transmit: return "Transmit"
        }
    }
    
    func titleForQos(_ qos: MqttManager.MqttQos) -> String {
        switch(qos) {
        case .atLeastOnce : return "At Least Once"
        case .atMostOnce : return "At Most Once"
        case .exactlyOnce : return "Exactly Once"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            cell.backgroundColor = UIColor.clear
    }

    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! MqttSettingsHeaderCell
        headerCell.backgroundColor = UIColor.clear
        headerCell.nameLabel.text = headerTitleForSection(section)
        let hasSwitch = section == SettingsSections.publish.rawValue || section == SettingsSections.subscribe.rawValue;
        headerCell.isOnSwitch.isHidden = !hasSwitch;
        if (hasSwitch) {
            let mqttSettings = MqttSettings.sharedInstance;
            if (section == SettingsSections.publish.rawValue) {
                headerCell.isOnSwitch.isOn = mqttSettings.isPublishEnabled
                headerCell.isOnChanged = { isOn in
                    mqttSettings.isPublishEnabled = isOn;
                }
            }
            else if (section == SettingsSections.subscribe.rawValue) {
                headerCell.isOnSwitch.isOn = mqttSettings.isSubscribeEnabled
                headerCell.isOnChanged = { [unowned self] isOn in
                    mqttSettings.isSubscribeEnabled = isOn;
                    self.subscriptionTopicChanged(nil, qos: mqttSettings.subscribeQos)
                }
            }
        }
        
        return headerCell;
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (headerTitleForSection(section) == nil) {
            UITableViewAutomaticDimension
            return 0.5;       // no title, so 0 height (hack: set to 0.5 because 0 height is not correctly displayed)
        }
        else {
            return MqttSettingsViewController.defaultHeaderCellHeight;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Focus on textfield if present
        if let editValueCell = tableView.cellForRow(at: indexPath) as? MqttSettingsEditValueCell {
            editValueCell.valueTextField?.becomeFirstResponder()
        }
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Go to next textField
        if (textField.returnKeyType == UIReturnKeyType.next) {
            let tag = textField.tag;
            var nextView = baseTableView.viewWithTag(tag+1)
            if (nextView == nil || nextView!.inputView != nil) {
                nextView = baseTableView.viewWithTag(((tag/10)+1)*10)
            }
            if let next = nextView {
                next.becomeFirstResponder()
                
                // Scroll to show it
                baseTableView.scrollToRow(at: indexPathFromTag(next.tag), at: .middle, animated: true)
            }
            else {
                textField.resignFirstResponder()
            }
        }
        
        return true;
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Update selected indexpath
        selectedIndexPath = indexPathFromTag(textField.tag)
        
        // Setup inputView if needed
        if (textField.inputView != nil) {
            // Setup valueTextField
            let isAction = selectedIndexPath.section ==  SettingsSections.subscribe.rawValue && selectedIndexPath.row == 1
            pickerViewType = isAction ? PickerViewType.action:PickerViewType.qos
            pickerView .reloadAllComponents()
            pickerView.tag = textField.tag      // pass the current textfield tag to the pickerView
            //pickerView.selectRow(<#row: Int#>, inComponent: 0, animated: false)
        }
        
        return true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.inputView == nil) {       // textfields with input view are not managed here
            let indexPath = indexPathFromTag(textField.tag)
            let section = indexPath.section
            let row = indexPath.row
            let mqttSettings = MqttSettings.sharedInstance;
            
            // Update settings with new values
            switch(section) {
            case SettingsSections.server.rawValue:
                if (row == 0) {         // Server Address
                    mqttSettings.serverAddress = textField.text
                }
                else if (row == 1) {    // Server Port
                    if let port = Int(textField.text!) {
                        mqttSettings.serverPort = port
                    }
                    else {
                        textField.text = nil;
                        mqttSettings.serverPort = MqttSettings.defaultServerPort
                    }
                }
                
            case SettingsSections.publish.rawValue:
                mqttSettings.setPublishTopic(row, topic: textField.text)
                
            case SettingsSections.subscribe.rawValue:
                let topic = textField.text
                mqttSettings.subscribeTopic = topic
                subscriptionTopicChanged(topic, qos: mqttSettings.subscribeQos)
                
            case SettingsSections.advanced.rawValue:
                if (row == 0) {            // Username
                    mqttSettings.username = textField.text;
                }
                else if (row == 1) {      // Password
                    mqttSettings.password = textField.text;
                }
                
            default:
                break;
            }
        }
    }

     // MARK: - KeyboardAwareViewController
    override func keyboardPositionChanged(_ keyboardFrame : CGRect, keyboardShown : Bool) {
        super.keyboardPositionChanged(keyboardFrame, keyboardShown:keyboardShown )
        
        if (IS_IPHONE) {
            let height = keyboardFrame.height
            baseTableView.contentInset =  UIEdgeInsetsMake(0, 0, height, 0);
        }
        
        //printLog(self, (__FUNCTION__), "keyboard size: \(height) appearing: \(keyboardShown)");
        if (keyboardShown) {
            baseTableView.scrollToRow(at: selectedIndexPath, at: .middle, animated: true)
        }
    }
    
    // MARK: - Input Toolbar
    
    @IBAction func onClickInputToolbarDone(_ sender: AnyObject) {
        let selectedPickerRow = pickerView.selectedRow(inComponent: 0);
        
        let indexPath = indexPathFromTag(pickerView.tag)
        let section = indexPath.section
        let row = indexPath.row
        let mqttSettings = MqttSettings.sharedInstance;

        // Update settings with new values
        switch(section) {
        case SettingsSections.publish.rawValue:
            mqttSettings.setPublishQos(row, qos: MqttManager.MqttQos(rawValue: selectedPickerRow)!)

        case SettingsSections.subscribe.rawValue:
            if (row == 0) {     // Topic Qos
                let qos = MqttManager.MqttQos(rawValue: selectedPickerRow)!
                mqttSettings.subscribeQos =  qos
                subscriptionTopicChanged(mqttSettings.subscribeTopic, qos: qos)
            }
            else if (row == 1) {    // Action
                mqttSettings.subscribeBehaviour = MqttSettings.SubscribeBehaviour(rawValue: selectedPickerRow)!
            }
        default:
            break;
        }

        // End editing
        self.view.endEditing(true)
        baseTableView.reloadData()      // refresh values
    }
    
    
    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewType == .action ? 2:3
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
//        let labels : [String];

        switch(pickerViewType) {
        case .qos:
            return titleForQos(MqttManager.MqttQos(rawValue: row)!)
        case .action:
            return titleForSubscribeBehaviour(MqttSettings.SubscribeBehaviour(rawValue: row)!)
        }
        
        
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    // MARK: - MqttManagerDelegate
    
    func onMqttConnected() {
        // Update status
        DispatchQueue.main.async(execute: { [unowned self] in
            self.baseTableView.reloadData()
            })
    }
   
    func onMqttDisconnected() {
        // Update status
        DispatchQueue.main.async(execute: { [unowned self] in
            self.baseTableView.reloadData()
            })

    }
    
    func onMqttMessageReceived(_ message : String, topic: String) {
    }
    
    func onMqttError(_ message : String) {
        DispatchQueue.main.async(execute: { [unowned self] in
            let alert = UIAlertController(title:"Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            // Update status
            self.baseTableView.reloadData()
            })
    }
}
