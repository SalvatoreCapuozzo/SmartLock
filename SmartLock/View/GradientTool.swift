//
//  GradientTool.swift
//  SmartLock
//
//  Created by Salvatore Capuozzo on 01/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import UIKit
import Foundation

class GradientTool {
    let gradientLayer = CAGradientLayer()
    
    enum color {
        case lightBlue
        case blue
        case green
        case red
        case walkthrough
    }
    
    required init (color: color) {
        var colors = [UIColor]()
        
        self.gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        self.gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        self.gradientLayer.locations = [0.0, 0.75, 1.0]
        
        switch color {
        case .lightBlue:
            colors = [
                UIColor(red: 54/255, green: 211/255, blue: 174/255, alpha: 1),
                UIColor(red: 121/255, green: 221/255, blue: 197/255, alpha: 1),
                UIColor(red: 214/255, green: 240/255, blue: 234/255, alpha: 1)
            ]
        case .blue:
            colors = [
                UIColor(red: 54/255, green: 119/255, blue: 211/255, alpha: 1),
                UIColor(red: 121/255, green: 131/255, blue: 221/255, alpha: 1),
                UIColor(red: 230/255, green: 214/255, blue: 240/255, alpha: 1)
            ]
        case .green:
            colors = [
                UIColor(red: 54/255, green: 211/255, blue: 65/255, alpha: 1),
                UIColor(red: 138/255, green: 208/255, blue: 121/255, alpha: 1),
                UIColor(red: 240/255, green: 240/255, blue: 214/255, alpha: 1)
            ]
        case .red:
            colors = [
                UIColor(red: 211/255, green: 54/255, blue: 54/255, alpha: 1),
                UIColor(red: 221/255, green: 121/255, blue: 122/255, alpha: 1),
                UIColor(red: 240/255, green: 214/255, blue: 214/255, alpha: 1)
            ]
        case .walkthrough:
            colors = [
                UIColor(red: 0/255, green: 202/255, blue: 157/255, alpha: 1),
                UIColor(red: 174/255, green: 239/255, blue: 170/255, alpha: 1),
                UIColor(red: 251/255, green: 255/255, blue: 193/255, alpha: 1)
            ]
        }
        
        self.gradientLayer.colors = colors.map { $0.cgColor }
        self.gradientLayer.name = "gradient"
    }
    
    // Manual selection of colors of the gradient
    required init (colors: [UIColor], middlePos: NSNumber) {
        self.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        self.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        self.gradientLayer.locations = [0.0, middlePos, 1.0]
        
        self.gradientLayer.colors = colors.map { $0.cgColor }
        self.gradientLayer.name = "gradient"
    }
    
    func apply(to view: UIView) {
        self.gradientLayer.frame = view.bounds
        view.layer.sublayers?.first { $0.name == "gradient" }?.removeFromSuperlayer()
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // Static implementation (suggested function to use)
    static func apply(colors: [UIColor], middlePos: NSNumber, to view: UIView) {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.locations = [0.0, middlePos, 1.0]
        
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.name = "gradient"
        
        gradientLayer.frame = view.bounds
        view.layer.sublayers?.first { $0.name == "gradient" }?.removeFromSuperlayer()
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
