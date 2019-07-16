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
    
    var justScanned: Bool = false
    var key: Int = 5

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUserInterface(type: 3)
        
        initBluetoothSerial()
        
        UserDefaults.standard.addObserver(self, forKeyPath: "receivedMessage", options: NSKeyValueObservingOptions.new, context: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnScreen))
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.startScan()
        }
        
    }
    
    func setupUserInterface(type: Int) {
        // Background Setup
        switch type {
        case 1:
            // Green Gradient
            GradientTool.apply(colors: [
                CustomColor.bottleGreen.uiColor(),
                UIColor(red: 0/255, green: 255/255, blue: 192/255, alpha: 1),
                CustomColor.leafGreen.uiColor()
                ], middlePos: 0.25, to: self.view)
        case 2:
            // Green Waves
            let waveView = WaveView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height/3), color: .green)
            waveView.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height - waveView.frame.size.height/2)
            waveView.realWaveColor = CustomColor.leafGreen.uiColor().withAlphaComponent(0.8)
            waveView.maskWaveColor = CustomColor.leafGreen.uiColor().withAlphaComponent(0.5)
            waveView.waveHeight = 60
            waveView.waveSpeed = 0.25
            waveView.waveCurvature = 0.5
            //waveView.layer.zPosition = interphoneTableView.layer.zPosition - 1
            self.view.addSubview(waveView)
            waveView.start()
            
            self.view.backgroundColor = CustomColor.bottleGreen.uiColor()
        case 3:
            // Blue Waves
            let waveView = WaveView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height/3), color: .green)
            waveView.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height - waveView.frame.size.height/2)
            waveView.realWaveColor = CustomColor.sparklingBlue.uiColor().withAlphaComponent(0.8)
            waveView.maskWaveColor = CustomColor.sparklingBlue.uiColor().withAlphaComponent(0.5)
            waveView.waveHeight = 60
            waveView.waveSpeed = 0.25
            waveView.waveCurvature = 0.5
            //waveView.layer.zPosition = interphoneTableView.layer.zPosition - 1
            self.view.addSubview(waveView)
            waveView.start()
            
            self.view.backgroundColor = CustomColor.lightBlue.uiColor()
        default:
            print("Invalid type")
        }
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
