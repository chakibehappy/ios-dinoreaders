import AVFoundation
import SwiftUI

var player: AVAudioPlayer!

class TextToSpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    let synth = AVSpeechSynthesizer()
    @Published var label: NSAttributedString?
    private var linesToSpeak: [String] = []
    @Published var currentLine: Int = 0
    @Published var finishSpeak: Bool = false
    
    @Published var storyLines: [String] = []
    @Published var storyBookStart: Bool = false
    
    @Published var totalAcquiredPoints: Int = 0
    @Published var totalWordCount: Int = 0
    
    @Published var lastPageIndex : Int = -1
    @Published var startTime : Int = 0
    
    override init() {
        super.init()
        synth.delegate = self
        lastPageIndex = -1
        totalAcquiredPoints = 0
        totalWordCount = 0
    }
    
    func playSound(audioFileName: String){
        let url = Bundle.main.url(forResource: audioFileName, withExtension: "wav")
        guard url != nil else {
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url!)
            player?.play()
        } catch {
            print("\(error)")
        }
    }
    
    func countTotalWords(page : Page, pageIndex : Int){
        if lastPageIndex < pageIndex {
            lastPageIndex = pageIndex
            var count = 0
            if let lines = page.fullText {
                if let playAudio = page.playAudio{
                    if !playAudio {
                        count = 0
                    }
                    else{
                        count = wordDictionaryCount(from: lines)
                    }
                }
                totalWordCount += count
                //print (count)
            }
            //print (totalWordCount)
        }
    }
    
    func reset() {
        storyBookStart = true
        stopSpeaking()
        finishSpeak = false
        label = nil
        linesToSpeak = []
        currentLine = 0
    }
    
    func speak(_ lines: [String]) {
        synth.stopSpeaking(at: .immediate)
        currentLine = 0
        linesToSpeak = lines
        storyLines = lines
        speakCurrentLine()
    }
    
    func stopSpeaking() {
        finishSpeak = true
        synth.stopSpeaking(at: .immediate)
        currentLine = -1
    }
    
    func speakCurrentLine() {
        if currentLine < 0 || linesToSpeak.count <= 0 {
            return
        }
        let utterance = AVSpeechUtterance(string: linesToSpeak[currentLine])
        // utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
        // utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Ting-Ting-compact")
        utterance.rate = 0.45
        synth.speak(utterance)
    }
    
    // Function to highlight text with red color and stroke
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if currentLine < 0 || linesToSpeak.isEmpty {
            return
        }
        if utterance.speechString != linesToSpeak[currentLine] {
            return
        }
        
        // Create a range from the start of the string to the end of the current character range
        let highlightRange = NSRange(location: 0, length: characterRange.location + characterRange.length)
            
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        // mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.red, range: characterRange) // highlight only the current speaking word
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.red, range: highlightRange)
        
        label = mutableAttributedString
        finishSpeak = false
        
        //print(characterRange.location)
        //print(utterance.speechString.count)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if currentLine < 0 || linesToSpeak.count <= 0 {
            return
        }
        if utterance.speechString != linesToSpeak[currentLine] {
            finishSpeak = false
            return
        }
        
        label = NSAttributedString(string: utterance.speechString)
        currentLine += 1
        
        if currentLine < linesToSpeak.count && currentLine > 0 && !finishSpeak {
            speakCurrentLine()
        } else {
            finishSpeak = true
        }
    }
}
