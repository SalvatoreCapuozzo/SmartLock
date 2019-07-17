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

extension AppViewController: BluetoothSerialDelegate {
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
    /*
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        //reloadView()
        //dismissKeyboard()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    */
    /*
    func serialDidChangeState() {
        //reloadView()
        if serial.centralManager.state != .poweredOn {
            //dismissKeyboard()
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }*/
    
    // Message sent to Arduino
    func sendToDevice(textToSend: String, completion: () -> ()) {
        if !serial.isReady {
            let alert = UIAlertController(title: "Dispositivo non connesso", message: "Connettere prima il dispositivo Bluetooth all'app", preferredStyle: .alert)
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
        
        // send the message
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
            self.sendToDevice(textToSend: String(describing: multMess), completion: {
                SoundsPlayer.playSound(soundName: "open-ended", ext: "mp3")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                    self.sendToDevice(textToSend: "chiudi", completion: {})
                })
            })
        case "deviceConnected":
            let connected = UserDefaults.standard.bool(forKey: "deviceConnected")
            if connected {
                GSMessage.showMessageAddedTo("Connesso all'interfono", type: .success, options: [.height(100), .textNumberOfLines(2)], inView: self.view, inViewController: self)
                self.justScanned = false
            }
        default:
            print("Error")
        }
    }
}

extension AppViewController {
    func startScan() {
        UserDefaults.standard.addObserver(self, forKeyPath: "deviceConnected", options: NSKeyValueObservingOptions.new, context: nil)
        // start scanning and schedule the time out
        serial.startScan()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(scanTimeOut), userInfo: nil, repeats: false)
    }
    
    /// Should be called 10s after we've begun scanning
    @objc func scanTimeOut() {
        // timeout has occurred, stop scanning and give the user the option to try again
        serial.stopScan()
        if !UserDefaults.standard.bool(forKey: "deviceConnected") {
            GSMessage.showMessageAddedTo("Tempo per la connessione scaduto", type: .error, options: [.height(100), .textNumberOfLines(2)], inView: self.view, inViewController: self)
            print("Scan timed out")
        }
        
        //tryAgainButton.isEnabled = true
    }
    
    /// Should be called 10s after we've begun connecting
    @objc func connectTimeOut() {
        
        // don't if we've already connected
        if let _ = serial.connectedPeripheral {
            return
        }
        
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        if let _ = selectedPeripheral {
            serial.disconnect()
            selectedPeripheral = nil
        }
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Failed to connect"
        hud?.hide(true, afterDelay: 2)
    }
    
    //MARK: BluetoothSerialDelegate
    
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        // check whether it is a duplicate
        for exisiting in peripherals {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
        }
        
        // add to the array, next sort & reload
        let theRSSI = RSSI?.floatValue ?? 0.0
        peripherals.append((peripheral: peripheral, RSSI: theRSSI))
        peripherals.sort { $0.RSSI < $1.RSSI }
        //tableView.reloadData()
        
        if autoConnect {
            selectPeripheral()
        }
    }
    
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        //tryAgainButton.isEnabled = true
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Failed to connect"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        //tryAgainButton.isEnabled = true
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Failed to connect"
        hud?.hide(true, afterDelay: 1.0)
        
    }
    
    func serialIsReady(_ peripheral: CBPeripheral) {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStartViewController"), object: self)
        //dismiss(animated: true, completion: nil)
    }
    
    func serialDidChangeState() {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        if serial.centralManager.state != .poweredOn {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStartViewController"), object: self)
            //dismiss(animated: true, completion: nil)
        }
    }
    
    
    //MARK: @objc functions
    
    @objc func cancel(_ sender: AnyObject) {
        // go back
        serial.stopScan()
        //dismiss(animated: true, completion: nil)
    }
    
    @objc func tryAgain(_ sender: AnyObject) {
        // empty array an start again
        peripherals = []
        //tableView.reloadData()
        //tryAgainButton.isEnabled = false
        serial.startScan()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(scanTimeOut), userInfo: nil, repeats: false)
    }
    
    func selectPeripheral(indexPath: IndexPath = IndexPath(row: 0, section: 0)) {
        if peripherals.count > 0 {
            // the user has selected a peripheral, so stop scanning and proceed to the next view
            serial.stopScan()
            selectedPeripheral = peripherals[(indexPath as NSIndexPath).row].peripheral
            serial.connectToPeripheral(selectedPeripheral!)
            progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
            progressHUD!.labelText = "Connecting"
            
            Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ScannerViewController.connectTimeOut), userInfo: nil, repeats: false)
        }
    }
}
