//
//  AudioController.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 21/09/23.
//

import Foundation
import AVFoundation

class AudioController{
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

    func play(audioFileName: String) {
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: nil, subdirectory: "AudioFiles") else {
            print("Audio file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch let error {
            print("Error playing audio file: \(error.localizedDescription)")
        }
    }

}
