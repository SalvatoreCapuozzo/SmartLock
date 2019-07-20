//
//  CustomBuilder.swift
//  SmartLock
//
//  Created by Salvatore Capuozzo on 01/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    // Extension utilities for UIButtons
    func subButton() -> UIButton? {
        if let button = subviews[0] as? UIButton {
            return button
        }
        return nil
    }
    
    func changeButtonColor(color: UIColor, textColor: UIColor) {
        if let button = self.subButton() {
            self.backgroundColor = color
            button.setTitleColor(textColor, for: .normal)
        }
    }
    
    func resizeButton(width: CGFloat, height: CGFloat) {
        if let button = self.subButton() {
            self.frame.size.width = width
            self.frame.size.height = height
            button.frame.size.width = width
            button.frame.size.height = height
            //button.titleLabel?.adjustsFontSizeToFitWidth = true
            //button.titleLabel?.minimumScaleFactor = 0.2
        }
    }
}

class CustomBuilder {
    static func makeButton(width: CGFloat, height: CGFloat, text: String, color: UIColor, textColor: UIColor) -> UIView {
        let btnView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        btnView.backgroundColor = color
        btnView.layer.cornerRadius = height/2
        btnView.layer.masksToBounds = false
        btnView.layer.zPosition = 5
        
        let button = UIButton(frame: btnView.frame)
        button.titleLabel?.font = UIFont.systemFont(ofSize: height/3.5)
        button.setTitleColor(textColor, for: .normal)

        button.layer.zPosition = btnView.layer.zPosition + 1
        button.frame.origin = .zero
        button.titleLabel?.textAlignment = .center
        button.setTitle(text, for: .normal)
        
        btnView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnView.layer.shadowOpacity = 0.25
        btnView.layer.shadowRadius = 0.0
        
        btnView.addSubview(button)
        
        return btnView
    }
    
    static func makeTextField(width: CGFloat, height: CGFloat, placeholder: String, keyboardType: UIKeyboardType, capitalized: Bool, isSecure: Bool) -> UITextField {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: width, height: height))
        textField.layer.cornerRadius = textField.frame.size.height/2
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        textField.layer.borderWidth = 1
        let emailPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = emailPaddingView
        textField.leftViewMode = .always
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: height/3.5)
        textField.autocorrectionType = .no
        textField.keyboardType = keyboardType
        textField.returnKeyType = .default
        textField.contentVerticalAlignment = .center
        textField.textAlignment = .left
        textField.isSecureTextEntry = isSecure
        if capitalized {
            textField.autocapitalizationType = .words
        } else {
            textField.autocapitalizationType = .none
        }
        textField.backgroundColor = .white
        return textField
    }
}

