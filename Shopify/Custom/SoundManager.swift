//
//  SoundManager.swift
//  Shopify
//
//  Created by Fabrice Etiennette on 19/09/2019.
//  Copyright © 2019 Fabrice Etiennette. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager {
    
    var audioPlayer: AVAudioPlayer?
    
    enum SoundEffect {
        case flip
        case shuffle
        case match
        case nomatch
    }
    
    func playSound(_ effect: SoundEffect) {
        var soundFilename = ""
        
        switch effect {
        case .flip:
            soundFilename = "cardflip"
        case .shuffle:
            soundFilename = "shuffle"
        case .match:
            soundFilename = "dingcorrect"
        case .nomatch:
            soundFilename = "dingwrong"
        }
         
        let bundlePath = Bundle.main.path(forResource: soundFilename, ofType: "wav")
        guard bundlePath != nil else {
            print("no sound file")
            return
        }
        
        let soundURL = URL(fileURLWithPath: bundlePath!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            
            audioPlayer?.play()
        } catch {
            print("couldn't create the audio player")
        }
    }
}
