//
//  CodeAccessViewController.swift
//  SmartLock
//
//  Created by Federica Ventriglia on 10/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import Foundation
import UIKit

class CodeAccessViewController: AppViewController {
    
    var goBackButton: UIButton!
    var codeTextField: UITextField!
    var accessButton: UIView!
    var user = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserInterface(type: 3)
        // Dummy Data for Testing
        //DataController().deleteData(entityName: "User")
        //DataController().addUser(name: "Federica", surname: "Ventriglia", code: "1234", isFamily: true, isManager: false)

        setupUserInterface(type: 3)
        codeTextField.becomeFirstResponder()
        UserDefaults.standard.addObserver(self, forKeyPath: "receivedMessage", options: NSKeyValueObservingOptions.new, context: nil)
        
        //maxX = view.bounds.maxX
        //midY = view.bounds.midY
        //maxY = view.bounds.maxY
        self.sendToDevice(textToSend: "chiudi", completion: {})
    }
    
    @objc override func cancel(_ sender: AnyObject) {
        // go back
        dismiss(animated: true, completion: nil)
    }
    
    override func setupUserInterface(type: Int) {
        super.setupUserInterface(type: type)
        goBackButton = UIButton(frame: CGRect(x: 8, y: UIApplication.shared.statusBarFrame.height + 8, width: self.view.frame.size.width/10, height: self.view.frame.size.width/10))
        goBackButton.setBackgroundImage(UIImage.init(named: "back"), for: .normal)
        goBackButton.contentMode = .scaleAspectFill
        goBackButton.backgroundColor = .clear
        goBackButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.view.addSubview(goBackButton)
        
        codeTextField = CustomBuilder.makeTextField(width: self.view.frame.size.width/3, height: self.view.frame.size.width/9, placeholder: "Codice utente", keyboardType: .numberPad, capitalized: false, isSecure: true)
        codeTextField.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2)
        self.view.addSubview(codeTextField)
        
        accessButton = CustomBuilder.makeButton(width: self.view.frame.size.width/3, height: self.view.frame.size.width/8, text: "Accedi", color: CustomColor.sparklingBlue.uiColor(), textColor: .white)
        accessButton.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2 + self.codeTextField.frame.height + 60)
        //accessButton.layer.cornerRadius = accessButton.frame.size.height/4
        accessButton.subButton()?.tintColor = .white
        accessButton.subButton()?.addTarget(self, action: #selector(checkCode), for: .touchUpInside)
        self.view.addSubview(accessButton)
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
                self.sendToDevice(textToSend: "apri", completion: {})
            }
        }
        //didLogin(method: "password", info: "Password: \(pass)")
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        codeTextField.resignFirstResponder()
//    }

    
    private func didLogin(method: String, info: String) {
        let message = "Grazie \(info)\nAccesso effettuato con successo"
        let alert = UIAlertController(title: "Accesso", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { [unowned self] (action: UIAlertAction!) in
            self.codeTextField.text = ""
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func failLogin(method: String, info: String) {
        let message = "Accesso Negato: \(info)"
        let alert = UIAlertController(title: "Errore", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Riprova", style: UIAlertAction.Style.default, handler: { [unowned self] (action: UIAlertAction!) in
            self.codeTextField.text = ""
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
