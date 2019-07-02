//
//  CustomColor.swift
//  SmartLock
//
//  Created by Salvatore Capuozzo on 02/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import Foundation
import UIKit

enum CustomColor {
    case fogGray
    case lightBlue
    case middleBlue
    case classicBlue
    case sparklingBlue
    case darkBlue
    case defaultBlue
    case emeraldGreen
    case leafGreen
    case bottleGreen
    
    func uiColor() -> UIColor {
        switch self {
        case .fogGray:
            return UIColor.lightGray.withAlphaComponent(0.5)
        case .lightBlue:
            return UIColor(red: 110/255, green: 190/255, blue: 249/255, alpha: 1)
        case .middleBlue:
            return UIColor(red: 85/255, green: 165/255, blue: 218/255, alpha: 1)
        case .classicBlue:
            return UIColor(red: 8/255, green: 115/255, blue: 185/255, alpha: 1)
        case .sparklingBlue:
            return UIColor(red: 57/255, green: 167/255, blue: 249/255, alpha: 1)
        case .darkBlue:
            return UIColor(red: 68/255, green: 101/255, blue: 173/255, alpha: 1)
        case .defaultBlue:
            return UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        case .emeraldGreen:
            return UIColor(red: 80/255, green: 200/255, blue: 120/255, alpha: 1)
        case .leafGreen:
            return UIColor(red: 0/255, green: 255/255, blue: 128/255, alpha: 1)
        case .bottleGreen:
            return UIColor(red: 0/255, green: 255/255, blue: 224/255, alpha: 1)
        }
    }
    
    func cgColor() -> CGColor {
        return uiColor().cgColor
    }
}
