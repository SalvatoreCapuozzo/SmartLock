//
//  SoundsPlayer.swift
//  SmartLock
//
//  Created by Salvatore Capuozzo on 16/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import AVFoundation

class SoundsPlayer {
    private static var player = AVAudioPlayer()
    static func playSound(soundName: String, ext: String) {
        let url = Bundle.main.url(forResource: soundName, withExtension: ext)!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            //guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
