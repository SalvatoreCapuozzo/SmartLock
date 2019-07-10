//
//  CodeAccessViewController.swift
//  SmartLock
//
//  Created by Federica Ventriglia on 10/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import Foundation
import UIKit

class CodeAccessViewController: UIViewController {
    
    
    var codeTextField: UITextField!
    var accessButton: UIView!
    var user = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dummy Data for Testing
        DataController().deleteData(entityName: "User")
        DataController().addUser(name: "Federica", surname: "Ventriglia", code: "1234", isFamily: true, isManager: false)

        setupUserInterface(type: 3)
        codeTextField.becomeFirstResponder()
        UserDefaults.standard.addObserver(self, forKeyPath: "receivedMessage", options: NSKeyValueObservingOptions.new, context: nil)
        
        //maxX = view.bounds.maxX
        //midY = view.bounds.midY
        //maxY = view.bounds.maxY
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
            self.createInterface()
            
        case 2:
            // Green Waves
            let waveView = WaveView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height/3), color: .green)
            waveView.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height - waveView.frame.size.height/2)
            waveView.realWaveColor = CustomColor.leafGreen.uiColor().withAlphaComponent(0.8)
            waveView.maskWaveColor = CustomColor.leafGreen.uiColor().withAlphaComponent(0.5)
            waveView.waveHeight = 60
            waveView.waveSpeed = 0.25
            waveView.waveCurvature = 0.5
            self.view.addSubview(waveView)
            waveView.start()
            
            self.view.backgroundColor = CustomColor.bottleGreen.uiColor()
            
            self.createInterface()
        case 3:
            // Blue Waves
            let waveView = WaveView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height/3), color: .green)
            waveView.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height - waveView.frame.size.height/2)
            waveView.realWaveColor = CustomColor.sparklingBlue.uiColor().withAlphaComponent(0.8)
            waveView.maskWaveColor = CustomColor.sparklingBlue.uiColor().withAlphaComponent(0.5)
            waveView.waveHeight = 60
            waveView.waveSpeed = 0.25
            waveView.waveCurvature = 0.5
           // waveView.layer.zPosition = interphoneTableView.layer.zPosition - 1
            self.view.addSubview(waveView)
            waveView.start()
            
            self.view.backgroundColor = CustomColor.lightBlue.uiColor()
           // add button for code
            self.createInterface()
            
        default:
            print("Invalid type")
        }
    }
    
    @objc func checkCode(_ sender: UIButton) {
        codeTextField.resignFirstResponder()
        // Regular access attempt. Add the code to handle the login and code.
        guard let pass = codeTextField.text else {
            // It should never get here
            return
        }
        print("Code inserito \(pass)")
        DataController().fetchData(entityName: "User", searchBy: [SearchField.code : pass as AnyObject]) {
            (outcome, results) in
            if outcome! {
                self.user = results
                guard !(results.isEmpty) else {
                    // It should never get here
                    self.failLogin(method: "code", info: "Codice Errato/Non Trovato")
                    return
                }
//                print(results[0]["name"])
                self.didLogin(method: "code", info: (results[0]["name"] as! String) )
            }
        }
        //didLogin(method: "password", info: "Password: \(pass)")
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        codeTextField.resignFirstResponder()
//    }

    
    private func didLogin(method: String, info: String) {
        let message = "Grazie \(info) Accesso effettuato con successo"
        let alert = UIAlertController(title: "Accesso", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { [unowned self] (action: UIAlertAction!) in
            self.codeTextField.text = ""
        }))
        self.present(alert, animated: false, completion: nil)
    }
    
    private func failLogin(method: String, info: String) {
        let message = "Accesso Negato: \(info)"
        let alert = UIAlertController(title: "Errore", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Riprova", style: UIAlertAction.Style.default, handler: { [unowned self] (action: UIAlertAction!) in
            self.codeTextField.text = ""
        }))
        self.present(alert, animated: false, completion: nil)
    }
    
    // Create UI
    func createInterface(){
        codeTextField = UITextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width/3, height:  self.view.frame.size.width/9))
        codeTextField.center = self.view.center
        codeTextField.layer.cornerRadius = codeTextField.frame.size.height/4
        codeTextField.placeholder = "Codice"
        codeTextField.borderStyle = .roundedRect
        codeTextField.backgroundColor = UIColor.white
        codeTextField.textColor = UIColor.black
        
        // Add UITextField as a subview
        self.view.addSubview(codeTextField)
        accessButton = CustomBuilder.makeButton(width: self.view.frame.size.width/3, height: self.view.frame.size.width/8, text: "Accedi", color: CustomColor.sparklingBlue.uiColor(), textColor: .white)
        accessButton.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2 + self.codeTextField.frame.height + 60)
        accessButton.layer.cornerRadius = accessButton.frame.size.height/4
        accessButton.subButton()?.tintColor = .white
        accessButton.subButton()?.addTarget(self, action: #selector(checkCode), for: .touchUpInside)
        self.view.addSubview(accessButton)
    }
}
