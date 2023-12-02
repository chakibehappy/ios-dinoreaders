import AVFoundation
import SwiftUI

class TextToSpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    let synth = AVSpeechSynthesizer()
    @Published var label: NSAttributedString?
    private var linesToSpeak : [Line] = []
    private var currentLine: Int = 0
    private var lineFullStops : [String] = []
    @Published var finishSpeak : Bool = false
    
    
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

    func speak(_ lines:[Line]) {
        currentLine = 0
        linesToSpeak = lines
        let fullLines = linesToSpeak.map { $0.text }.joined(separator: " ")
        // Split the fullLines string based on '.', '!', and '?' into an array of substrings
        let sentences = fullLines.split(whereSeparator: { ".!?".contains($0) })

        // Convert the substrings to an array of strings
        lineFullStops = sentences.map { String($0) }
        synth.continueSpeaking()
        speakCurrentLine()
    }
    func stopSpeaking() {
        synth.pauseSpeaking(at: .immediate)
        currentLine = -1
    }
    
    func speakCurrentLine(){
        if(currentLine < 0){
            return
        }
        let utterance = AVSpeechUtterance(string: linesToSpeak[currentLine].text)
//        	let utterance = AVSpeechUtterance(string: lineFullStops[currentLine])
//        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
//        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Ting-Ting-compact")
        utterance.rate = 0.45
        synth.speak(utterance)
    }
    
    // Functions to highlight text
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if(currentLine < 0){
            return
        }
        if utterance.speechString != linesToSpeak[currentLine].text{
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
        if(currentLine < 0){
            return
        }
        if utterance.speechString != linesToSpeak[currentLine].text{
            finishSpeak = false
            return
        }
        label = NSAttributedString(string: utterance.speechString)
        currentLine+=1
        if currentLine < linesToSpeak.count && currentLine > 0 {
            speakCurrentLine()
        }
        else{
            finishSpeak = true
        }
    }
    
}
