//
//  ScannerViewController.swift
//  HM10_Serial
//
//  Created by Salvatore Capuozzo on 06/05/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

final class ScannerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BluetoothSerialDelegate {
    
    var tryAgainButton: UIButton!
    var tableView: UITableView!
    var goBackButton: UIButton!
    
    var autoConnect: Bool = true
    
    //MARK: Variables
    
    /// The peripherals that have been discovered (no duplicates and sorted by asc RSSI)
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    
    /// The peripheral the user has selected
    var selectedPeripheral: CBPeripheral?
    
    /// Progress hud shown
    var progressHUD: MBProgressHUD?
    
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserInterface()
        
        // tell the delegate to notificate US instead of the previous view if something happens
        serial.delegate = self
        
        if serial.centralManager.state != .poweredOn {
            title = "Bluetooth not turned on"
            return
        }
        
        // start scanning and schedule the time out
        serial.startScan({})
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ScannerViewController.scanTimeOut), userInfo: nil, repeats: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUserInterface() {
        // Interphone TableView Setup
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width*2/3, height: self.view.frame.size.height*3/5))
        tableView.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height - tableView.frame.size.height/2 - 16)
        tableView.backgroundColor = .clear
        
        tableView.layer.cornerRadius = 20
        tableView.layer.masksToBounds = true
        tableView.layer.borderColor = UIColor.white.cgColor
        tableView.layer.borderWidth = 5
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        goBackButton = UIButton(frame: CGRect(x: 8, y: 28, width: 40, height: 40))
        goBackButton.setImage(#imageLiteral(resourceName: "faceid"), for: .normal)
        goBackButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.view.addSubview(goBackButton)
        
        tryAgainButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 48, y: 28, width: 40, height: 40))
        tryAgainButton.setImage(#imageLiteral(resourceName: "faceid"), for: .normal)
        tryAgainButton.addTarget(self, action: #selector(tryAgain), for: .touchUpInside)
        
        // tryAgainButton is only enabled when we've stopped scanning
        tryAgainButton.isEnabled = false
        self.view.addSubview(tryAgainButton)
        
        // Blue Waves
        let waveView = WaveView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height/3), color: .green)
        waveView.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height - waveView.frame.size.height/2)
        waveView.realWaveColor = CustomColor.sparklingBlue.uiColor().withAlphaComponent(0.8)
        waveView.maskWaveColor = CustomColor.sparklingBlue.uiColor().withAlphaComponent(0.5)
        waveView.waveHeight = 60
        waveView.waveSpeed = 0.25
        waveView.waveCurvature = 0.5
        waveView.layer.zPosition = tableView.layer.zPosition - 1
        self.view.addSubview(waveView)
        waveView.start()
        
        self.view.backgroundColor = CustomColor.lightBlue.uiColor()
    }
    
    /// Should be called 10s after we've begun scanning
    @objc func scanTimeOut() {
        // timeout has occurred, stop scanning and give the user the option to try again
        serial.stopScan()
        tryAgainButton.isEnabled = true
        title = "Done scanning"
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
    
    
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return a cell with the peripheral name as text in the label
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        //let label = cell.viewWithTag(1) as! UILabel?
        cell.textLabel?.text = peripherals[(indexPath as NSIndexPath).row].peripheral.name
        //label?.text = peripherals[(indexPath as NSIndexPath).row].peripheral.name
        return cell
    }
    
    
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectPeripheral(indexPath: indexPath)
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
        tableView.reloadData()
        
        if autoConnect {
            selectPeripheral()
        }
    }
    
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        tryAgainButton.isEnabled = true
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Failed to connect"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        tryAgainButton.isEnabled = true
        
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
        dismiss(animated: true, completion: nil)
    }
    
    func serialDidChangeState() {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        if serial.centralManager.state != .poweredOn {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStartViewController"), object: self)
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    //MARK: @objc functions
    
    @objc func cancel(_ sender: AnyObject) {
        // go back
        serial.stopScan()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func tryAgain(_ sender: AnyObject) {
        // empty array an start again
        peripherals = []
        tableView.reloadData()
        tryAgainButton.isEnabled = false
        title = "Scanning ..."
        serial.startScan({})
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ScannerViewController.scanTimeOut), userInfo: nil, repeats: false)
    }
    
    func selectPeripheral(indexPath: IndexPath = IndexPath(row: 0, section: 0)) {
        if peripherals.count > 0 {
            // the user has selected a peripheral, so stop scanning and proceed to the next view
            serial.stopScan()
            selectedPeripheral = peripherals[(indexPath as NSIndexPath).row].peripheral
            serial.connectToPeripheral(selectedPeripheral!)
            progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
            progressHUD!.labelText = "Connecting"
            
            print("Connecting...")
            
            Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ScannerViewController.connectTimeOut), userInfo: nil, repeats: false)
        }
    }
    
}

