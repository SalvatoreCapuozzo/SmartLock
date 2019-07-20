//
//  StyleManager.swift
//  SmartLock
//
//  Created by Salvatore Capuozzo on 17/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import Foundation

class StyleManager {
    static let shared = StyleManager()
    
    private var styleType: StyleType = .blueWave
    
    func setStyle(type: StyleType) {
        self.styleType = type
    }
    
    func getButton(size: CGSize, center: CGPoint, image: UIImage? = nil, text: String? = nil) -> UIView {
        var buttonText: String = ""
        var color: UIColor = .clear
        if let txt = text {
            buttonText = txt
            color = .white
        }
        var button = UIView()
        switch styleType {
        case .greenGradient:
            button = CustomBuilder.makeButton(width: size.width, height: size.height, text: buttonText, color: UIColor(red: 20/255, green: 255/255, blue: 170/255, alpha: 1), textColor: .white)
        case .greenWave:
            button = CustomBuilder.makeButton(width: size.width, height: size.height, text: buttonText, color: CustomColor.leafGreen.uiColor(), textColor: color)
        case .blueWave:
            button = CustomBuilder.makeButton(width: size.width, height: size.height, text: buttonText, color: CustomColor.sparklingBlue.uiColor(), textColor: color)
        }
        button.center = center
        button.layer.cornerRadius = button.frame.size.height/4
        //button.layer.zPosition = self.interphoneTableView.layer.zPosition
        let img = image?.withRenderingMode(.alwaysTemplate)
        button.subButton()?.setImage(img, for: .normal)
        button.subButton()?.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.subButton()?.imageView!.contentMode = .scaleAspectFit
        button.subButton()?.tintColor = .white
        button.subButton()?.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.subButton()?.layer.shadowRadius = 0
        button.subButton()?.layer.shadowOpacity = 0.1
        button.subButton()?.layer.masksToBounds = false

        return button
    }
    
    func setBackgroundStyle(to view: UIView) {
        switch styleType {
        case .greenGradient:
            GradientTool.apply(colors: [
                CustomColor.bottleGreen.uiColor(),
                UIColor(red: 0/255, green: 255/255, blue: 192/255, alpha: 1),
                CustomColor.leafGreen.uiColor()
                ], middlePos: 0.25, to: view)
        case .greenWave:
            let waveView = WaveView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height/3), color: .green)
            waveView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - waveView.frame.size.height/2)
            waveView.realWaveColor = CustomColor.leafGreen.uiColor().withAlphaComponent(0.8)
            waveView.maskWaveColor = CustomColor.leafGreen.uiColor().withAlphaComponent(0.5)
            waveView.waveHeight = 60
            waveView.waveSpeed = 0.25
            waveView.waveCurvature = 0.5
            //waveView.layer.zPosition = interphoneTableView.layer.zPosition - 1
            view.addSubview(waveView)
            waveView.start()
            
            view.backgroundColor = CustomColor.bottleGreen.uiColor()
        case .blueWave:
            let waveView = WaveView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height/3), color: .green)
            waveView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - waveView.frame.size.height/2)
            waveView.realWaveColor = CustomColor.sparklingBlue.uiColor().withAlphaComponent(0.8)
            waveView.maskWaveColor = CustomColor.sparklingBlue.uiColor().withAlphaComponent(0.5)
            waveView.waveHeight = 60
            waveView.waveSpeed = 0.25
            waveView.waveCurvature = 0.5
            //waveView.layer.zPosition = interphoneTableView.layer.zPosition - 1
            view.addSubview(waveView)
            waveView.start()
            
            view.backgroundColor = CustomColor.lightBlue.uiColor()
        }
    }
}

enum StyleType {
    case greenGradient
    case greenWave
    case blueWave
    // Inserirne altri
}
