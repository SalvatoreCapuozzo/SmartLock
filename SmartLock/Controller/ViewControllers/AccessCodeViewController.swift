//
//  CodeAccessViewController.swift
//  SmartLock
//
//  Created by Federica Ventriglia on 10/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import Foundation
import UIKit

class AccessCodeViewController: AppViewController {
    
    var goBackButton: UIButton!
    var codeTextField: UITextField!
    var accessButton: UIView!
    var user = [[String: AnyObject]]()
    //var justSent: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserInterface()
        // Dummy Data for Testing
        //DataController().deleteData(entityName: "User")
        //DataController().addUser(name: "Federica", surname: "Ventriglia", code: "1234", isFamily: true, isManager: false)

        codeTextField.becomeFirstResponder()
    }
    
    @objc override func cancel(_ sender: AnyObject) {
        // go back
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    override func setupUserInterface() {
        super.setupUserInterface()
        goBackButton = UIButton(frame: CGRect(x: 8, y: UIApplication.shared.statusBarFrame.height + 8, width: self.view.frame.size.width/10, height: self.view.frame.size.width/10))
        goBackButton.setBackgroundImage(UIImage.init(named: "back"), for: .normal)
        goBackButton.contentMode = .scaleAspectFill
        goBackButton.backgroundColor = .clear
        goBackButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.view.addSubview(goBackButton)
        
        codeTextField = CustomBuilder.makeTextField(width: self.view.frame.size.width/3, height: self.view.frame.size.width/9, placeholder: "Codice utente", keyboardType: .numberPad, capitalized: false, isSecure: true)
        codeTextField.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2)
        self.view.addSubview(codeTextField)
        
        accessButton = StyleManager.shared.getButton(size: CGSize(width: self.view.frame.size.width/3, height: self.view.frame.size.width/8), center: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2 + self.codeTextField.frame.height + 30), text: "Accedi")
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
        DataController().fetchData(entity: .user, searchBy: [.code : pass as AnyObject]) {
            (outcome, results) in
            if outcome! {
                self.user = results
                guard !(results.isEmpty) else {
                    // It should never get here
                    self.failLogin(method: "code", info: "Codice Errato/Non Trovato")
                    return
                }
                self.didLogin(method: "code", info: (results[0]["name"] as! String) )
            }
        }
    }


    
    private func didLogin(method: String, info: String) {
        let message = "Grazie \(info)\nAccesso effettuato con successo"
        self.sendToDevice(textToSend: "apri") {
            GSMessage.showMessageAddedTo(message, type: .success, options: [.height(100), .textNumberOfLines(2)], inView: self.view, inViewController: self)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.0, execute: {
                let transition = CATransition()
                transition.duration = 0.5
                transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                transition.type = CATransitionType.push
                transition.subtype = CATransitionSubtype.fromLeft
                self.view.window!.layer.add(transition, forKey: nil)
                self.dismiss(animated: false, completion: nil)
            })
        }
        self.codeTextField.text = ""
    }
    
    private func failLogin(method: String, info: String) {
        let message = "Accesso Negato: \(info)"
        GSMessage.showMessageAddedTo(message, type: .error, options: [.height(100), .textNumberOfLines(2)], inView: self.view, inViewController: self)
        self.codeTextField.text = ""
    }
}
