//
//  AppViewController.swift
//  SmartLock
//
//  Created by Salvatore Capuozzo on 16/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import UIKit
import CoreBluetooth
import AVFoundation

class AppViewController: UIViewController {
    var users = [[String: AnyObject]]()
    
    var receivedMessage: String = ""
    var messageSent: Bool = false
    
    var autoConnect: Bool = true
    
    //MARK: Variables
    
    /// The peripherals that have been discovered (no duplicates and sorted by asc RSSI)
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    
    /// The peripheral the user has selected
    var selectedPeripheral: CBPeripheral?
    
    /// Progress hud shown
    var progressHUD: MBProgressHUD?
    
    var justScanned: Bool = true
    var key: Int = 5

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUserInterface()
        
        if let _ = self as? AccessScreenViewController {
            initBluetoothSerial()
            UserDefaults.standard.addObserver(self, forKeyPath: "receivedMessage", options: NSKeyValueObservingOptions.new, context: nil)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnScreen))
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.startScan()
        }
        
    }
    
    func setupUserInterface() {
        // Background Setup
        StyleManager.shared.setBackgroundStyle(to: self.view)
    }
    
    @objc func tappedOnScreen() {
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
