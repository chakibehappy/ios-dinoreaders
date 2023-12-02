//
//  AudioController.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 21/09/23.
//

import Foundation
import AVFoundation

var audioPlayer: AVAudioPlayer?

func playSound(sound : String, type : String){
    if let path = Bundle.main.path(forResource: sound, ofType: type){
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        }
        catch let error {
            print(error)
        }
    }
}
