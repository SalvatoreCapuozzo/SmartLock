//
//  BluetoothProtocolImplementation.swift
//  SmartLock
//
//  Created by Salvatore Capuozzo on 10/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import CoreBluetooth

/// The option to add a \n or \r or \r\n to the end of the send message
enum MessageOption: Int {
    case noLineEnding,
    newline,
    carriageReturn,
    carriageReturnAndNewline
}

/// The option to add a \n to the end of the received message (to make it more readable)
enum ReceivedMessageOption: Int {
    case none,
    newline
}

extension AccessScreenViewController: BluetoothSerialDelegate {
    func initBluetoothSerial() {
        serial = BluetoothSerial(delegate: self)
    }
    
    //MARK: BluetoothSerialDelegate
    
    // Message received from the Arduino
    func serialDidReceiveString(_ message: String) {
        // add the received text to the textView, optionally with a line break at the end
        //mainTextView.text! += message
        print(message)
        /*
         if message != "Test... \n" {
         print("Ok")
         }*/
        if let firstChar = message.first {
            let firstCharString = String(describing: firstChar)
            if let _ = Int(firstCharString) {
                receivedMessage = message
                receivedMessage.removeLast()
                if let intMess = Int(receivedMessage) {
                    UserDefaults.standard.set(intMess, forKey: "receivedMessage")
                }
            }
        }
        
        
        
        //let pref = UserDefaults.standard.integer(forKey: ReceivedMessageOptionKey)
        //if pref == ReceivedMessageOption.newline.rawValue { mainTextView.text! += "\n" }
        //textViewScrollToBottom()
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        //reloadView()
        //dismissKeyboard()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState() {
        //reloadView()
        if serial.centralManager.state != .poweredOn {
            //dismissKeyboard()
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
    // Message sent to Arduino
    func textFieldShouldReturn(textToSend: String, completion: () -> ()) {
        if !serial.isReady {
            let alert = UIAlertController(title: "Not connected", message: "What am I supposed to send this to?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: { action -> Void in self.dismiss(animated: true, completion: nil) }))
            present(alert, animated: true, completion: nil)
            //messageField.resignFirstResponder()
            //return true
        }
        
        // send the message to the bluetooth device
        // but fist, add optionally a line break or carriage return (or both) to the message
        let pref = UserDefaults.standard.integer(forKey: MessageOptionKey)
        //var msg = messageField.text!
        
        var msg = textToSend
        switch pref {
        case MessageOption.newline.rawValue:
            msg += "\n"
        case MessageOption.carriageReturn.rawValue:
            msg += "\r"
        case MessageOption.carriageReturnAndNewline.rawValue:
            msg += "\r\n"
        default:
            msg += ""
        }
        
        // send the message and clear the textfield
        serial.sendMessageToDevice(msg)
        completion()
        //messageField.text = ""
        //return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "receivedMessage":
            let intMess = UserDefaults.standard.integer(forKey: "receivedMessage")
            let multMess = intMess*key
            print(multMess)
            print("")
            self.textFieldShouldReturn(textToSend: String(describing: multMess), completion: {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                    self.textFieldShouldReturn(textToSend: "chiudi", completion: {})
                })
            })
        default:
            print("Error")
        }
    }
}
