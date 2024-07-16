import AVFoundation
import SwiftUI

class TextToSpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    let synth = AVSpeechSynthesizer()
    @Published var label: NSAttributedString?
    private var linesToSpeak: [String] = []
    @Published var currentLine: Int = 0
    @Published var finishSpeak: Bool = false
    
    override init() {
        super.init()
        synth.delegate = self
    }
    
    func reset() {
        finishSpeak = false
        stopSpeaking()
        label = nil
        linesToSpeak = []
        currentLine = 0
    }
    
    func speak(_ lines: [String]) {
        currentLine = 0
        linesToSpeak = lines
        synth.continueSpeaking()
        speakCurrentLine()
    }
    
    func stopSpeaking() {
        synth.pauseSpeaking(at: .immediate)
        currentLine = -1
    }
    
    func speakCurrentLine() {
        if currentLine < 0 {
            return
        }
        let utterance = AVSpeechUtterance(string: linesToSpeak[currentLine])
        // let utterance = AVSpeechUtterance(string: lineFullStops[currentLine])
        // utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
        // utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Ting-Ting-compact")
        utterance.rate = 0.45
        synth.speak(utterance)
    }
    
    // Function to highlight text with red color and stroke
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if currentLine < 0 {
            return
        }
        if utterance.speechString != linesToSpeak[currentLine] {
            return
        }
        
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.red, range: characterRange)
        
        label = mutableAttributedString
        finishSpeak = false
        
        print(characterRange.location)
        print(utterance.speechString.count)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if currentLine < 0 {
            return
        }
        if utterance.speechString != linesToSpeak[currentLine] {
            finishSpeak = false
            return
        }
        
        label = NSAttributedString(string: utterance.speechString)
        currentLine += 1
        
        if currentLine < linesToSpeak.count && currentLine > 0 {
            speakCurrentLine()
        } else {
            finishSpeak = true
        }
    }
}
