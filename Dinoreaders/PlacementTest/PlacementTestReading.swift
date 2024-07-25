import Speech
import SwiftUI
import AVFoundation
import SwiftWhisper
import AVKit

struct PlacementTestReading: View {
    
    let storyPageData: StoryPageData
    let book: SingleBook
    let bookDataPath: String
    let activePage : Int
    let readingLevel : Int
    @ObservedObject var ttsManager = TextToSpeechManager()
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var settings : UserSettings
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    @State private var task : SFSpeechRecognitionTask!
    @State private var isStartRecording : Bool = false
    @State private var enableSpeak : Bool = false
    
    @State private var speechResultText : String = ""
    @State private var speechResultLabel: NSAttributedString?
    @State private var lineToSpeak : String = ""
    // for testing on emulator due poor audio quality
    let testingLines = [
        "Hello, how are you today?",
        "I love you, I love you.",
        "Good night baby"
    ]
    @State private var recordingLine : Int = 0
    @State private var currentWordsToCheck : [String] = []
    @State private var currentCorrectWords : [String] = []
    
    @State private var isTextToSpeechActive : Bool = false
    @State private var isHighlightingLine = false
    @State private var delayDuration = 1.75

    @State private var navigateToNextPage: Bool = false
    @State private var navigateToNextScreen: Bool = false

    @State private var startSpeakingWorkItem: DispatchWorkItem?

    @State private var testResultMsg = ""
    
    func requestSpeechPermission(){
        SFSpeechRecognizer.requestAuthorization{ (authState) in
            OperationQueue.main.addOperation {
                if authState == .authorized{
                    enableSpeak = true
//                    print("Speech Recognition is autorized")
                }
                else if authState == .denied{
                    print("Speech Recognition is denied")
                }
                else if authState == .notDetermined{
                    // user dont have speech recog
                    print("Speech Recognition is not determined")
                }
                else if authState == .restricted{
                    // restricted using speech recog
                    print("Speech Recognition is restricted")
                }
            }
        }
    }

    
    func startSpeechRecognition(){
        // Create a new request every time we start recognition
        let request = SFSpeechAudioBufferRecognitionRequest()
        
        var isFinishSpeak = false
        
        if (currentWordsToCheck.count <= 0){
            currentWordsToCheck = ttsManager.storyLines[recordingLine].split(separator: " ").map { String($0).trimmingCharacters(in: .punctuationCharacters)}
            //currentWordsToCheck = testingLines[recordingLine].split(separator: " ").map { String($0).trimmingCharacters(in: .punctuationCharacters) }
        }
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat){ (buffer, _) in
            request.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let error{
            print(error.localizedDescription)
        }
        
        guard let mySpeechRecognition = SFSpeechRecognizer() else{
            print("Recognition is not allow on your local")
            return
        }
        
        if !mySpeechRecognition.isAvailable{
            print("Recognition is free rigth now, please try again after some time")
        }
        
        
        task = speechRecognizer?.recognitionTask(with: request, resultHandler: {(response, error) in
            guard let response = response else{
                if error != nil{
                    print(error.debugDescription)
                }else{
                    print("Problem in giving the response")
                }
                return
            }
            
            let message = response.bestTranscription.formattedString
            var tempCorrectWordToCheck = currentWordsToCheck
            currentCorrectWords = []
            
            speechResultText = message
            print(message)
            
            let speechWords = speechResultText.split(separator: " ").map { String($0) }
            for speechWord in speechWords {
                var i = 0
                for targetWord in tempCorrectWordToCheck{
                    if speechWord.lowercased() == targetWord.lowercased() {
                        currentCorrectWords.append(targetWord)
                        tempCorrectWordToCheck.remove(at: i)
                        break
                    }
                    i += 1
                }
            }
            
            let linesTarget = ttsManager.storyLines[recordingLine]
            //let linesTarget = testingLines[recordingLine]
            
            let mutableAttributedString = NSMutableAttributedString(string: linesTarget)
            self.highlightMatchingWords(speechResultText: currentCorrectWords.joined(separator: " "), in: mutableAttributedString)
            self.speechResultLabel = mutableAttributedString
            
            print(tempCorrectWordToCheck.count)
            if tempCorrectWordToCheck.count <= 0 {
                if !isFinishSpeak {
                    ttsManager.totalAcquiredPoints += currentCorrectWords.count
                    currentCorrectWords = []
                    isFinishSpeak = true
                    ttsManager.playSound(audioFileName: "success")
                    
                    let delay = DispatchTimeInterval.milliseconds(Int(750))
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        isStartRecording = false
                        self.cancelSpeechRecognition()
                        if (recordingLine < ttsManager.storyLines.count - 1){
                            currentWordsToCheck = []
                            recordingLine += 1
                        }
                        else{
                            if activePage < storyPageData.pages.count - 1 {
                                navigateToNextPage = true
                            } else{
                                sendPlacementTestResult()
                            }
                        }
                    }
                }
            }
        })
    }
    
    func highlightMatchingWords(speechResultText: String, in mutableAttributedString: NSMutableAttributedString) {
        if (speechResultText.count == 0){
            return
        }
        var speechWords = speechResultText.split(separator: " ").map { String($0).trimmingCharacters(in: .punctuationCharacters) }
        let targetWords = mutableAttributedString.string.split(separator: " ").map { String($0) }
        
        var currentLocation = 0;
        for (index, targetWord) in targetWords.enumerated() {
            var i = 0
            for speechWord in speechWords {
                let cleanedTargetWord = targetWord.trimmingCharacters(in: .punctuationCharacters)
                if speechWord.lowercased() == cleanedTargetWord.lowercased() {
                    speechWords.remove(at: i)
                    let highlightRange = NSRange(location: currentLocation, length: targetWord.count + 1)
                    mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: highlightRange)
                    break
                }
                i += 1
            }
            currentLocation += targetWord.count
            if(index > 0){
                currentLocation += 1
            }
        }
    }

    func cancelSpeechRecognition(){
        if let task = task {
            print("Finishing and canceling task")
            task.finish()
            task.cancel()
            self.task = nil
        }
        
        if audioEngine.isRunning {
            print("Stopping audio engine")
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        request.endAudio()
    }
    
    func StartTextToSpeech() {
        
        ttsManager.countTotalWords(page: storyPageData.pages[activePage], pageIndex: activePage)
        
        if ttsManager.storyBookStart || activePage > 0 {
            ttsManager.playSound(audioFileName: "flip_page_2")
        }
        
        let delay = DispatchTimeInterval.milliseconds(Int(delayDuration * 1000))
        if let playAudio = storyPageData.pages[activePage].playAudio, playAudio {
            if (!isHighlightingLine)
            {
                if storyPageData.pages[activePage].lines.count > 0 {
                    if let text = storyPageData.pages[activePage].fullText{
                        let pattern = "([^.!?]+[.!?])"
                        let regex = try! NSRegularExpression(pattern: pattern, options: [])
                        let nsString = text as NSString
                        let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

                        let trimmedComponents = results.map {
                            nsString.substring(with: $0.range).trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        
                        startSpeakingWorkItem = DispatchWorkItem {
                            self.ttsManager.speak(trimmedComponents)
                            self.isHighlightingLine = true
                        }

                        if let workItem = startSpeakingWorkItem {
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
                        }
                    }
                }
            }
        }
        else{
            ttsManager.reset()
        }
    }
    
    private func cancelScheduledTextToSpeech() {
        ttsManager.stopSpeaking()
        startSpeakingWorkItem?.cancel()
        isHighlightingLine = false
        print("Scheduled speech canceled")
    }
    
    func sendPlacementTestResult() {
        var readingLevelResult = settings.ReadingLevel
        var percentage = 0;
        
        if ttsManager.totalAcquiredPoints > 0 {
            let percentageFloat = Float(ttsManager.totalAcquiredPoints) / Float(ttsManager.totalWordCount) * 100
            percentage = Int(round(percentageFloat))
        }

        if percentage >= 90 {
            readingLevelResult = readingLevel
        } else {
            if readingLevel > settings.ReadingLevel {
                readingLevelResult =  max(readingLevel - 1, 1)
            }
        }
        
        let messageText = "\nYour Reading Level is "
        testResultMsg = "The result is " + String(percentage) + " %" + messageText + GradeLabel.gradeName(at: readingLevelResult - 1);
        settings.ReadingLevel = readingLevelResult
        
        
        let url = URL(string: API.SAVEPLACEMENTTESTRESULT_API)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "user_id": UserDefaultManager.UserID,
            "profile_id": UserDefaultManager.ProfileID,
            "book_id": book.id,
            "total_word_count": ttsManager.totalWordCount,
            "total_right_word_count": ttsManager.totalAcquiredPoints,
            "reading_time": 30,
            "reading_level_result": readingLevelResult
        ]
        
        print(requestBody)

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            print("Failed to serialize JSON: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to save reading history: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Unexpected response status code")
                return
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Reading history saved successfully")
                print("Response: \(responseString)")
                navigateToNextScreen = true
            } else {
                print("Reading history saved successfully, but failed to decode response data")
            }
        }
        task.resume()
    }

    
    init(storyPageData: StoryPageData, bookDataPath: String, book: SingleBook, activePage: Int, ttsManager: TextToSpeechManager, readingLevel : Int){
        self.storyPageData = storyPageData
        self.bookDataPath = bookDataPath
        self.book = book
        self.activePage = activePage
        self.ttsManager = ttsManager
        self.readingLevel = readingLevel
        requestSpeechPermission()
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                HStack {
                    GeometryReader { geometry in
                        AsyncImage(url: URL(string: bookDataPath + storyPageData.pages[activePage].imgUrl.replacingOccurrences(of: "images", with: "images_ori"))) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                if Int(storyPageData.pages[activePage].width) <= Int(storyPageData.pages[activePage].height) {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .ignoresSafeArea(.all)
                                } else {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .ignoresSafeArea(.all)
                                }
                            case .failure(let error):
                                Text("Error: \(error.localizedDescription)")
                            @unknown default:
                                Text("Unknown state")
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                }
                
                
                
                GeometryReader { geometry in
                    ZStack {
                        
                        if let playAudio = storyPageData.pages[activePage].playAudio, playAudio {
                            if let text = storyPageData.pages[activePage].fullText{
                                let pattern = "([^.!?]+[.!?])"
                                let regex = try! NSRegularExpression(pattern: pattern, options: [])
                                let nsString = text as NSString
                                let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
                                let trimmedComponents = results.map {
                                    nsString.substring(with: $0.range).trimmingCharacters(in: .whitespacesAndNewlines)
                                }
                                if ttsManager.currentLine >= 0 && ttsManager.currentLine < trimmedComponents.count {
                                    let storyText : NSAttributedString = NSAttributedString(string: trimmedComponents[ttsManager.currentLine])
                                    if let speakerLabel = ttsManager.label{
                                        if trimmedComponents[ttsManager.currentLine] == speakerLabel.string{
                                            StrokeTextFull(text: speakerLabel.string, textWithAttribute: AttributedString(speakerLabel), width: 2.5, color: .white)
                                                .foregroundColor(.black)
                                                .font(.custom("Poppins-Medium", size: 26))
                                                .padding(.leading, 60).padding(.bottom, 20)
                                        }
                                        else{
                                            StrokeTextFull(text: storyText.string, textWithAttribute: AttributedString(storyText), width: 2.5, color: .white)
                                                .foregroundColor(.black)
                                                .font(.custom("Poppins-Medium", size: 26))
                                                .padding(.leading, 60).padding(.bottom, 20)
                                        }
                                    }
                                    else{
                                        StrokeTextFull(text: storyText.string, textWithAttribute: AttributedString(storyText), width: 2.5, color: .white)
                                            .foregroundColor(.black)
                                            .font(.custom("Poppins-Medium", size: 26))
                                            .padding(.leading, 60).padding(.bottom, 20)
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottomLeading)
                }
                
                VStack {
                    HStack {
                        Spacer()
                        if activePage < storyPageData.pages.count - 1 {
                            NavigationLink(
                                destination: PlacementTestReading(
                                    storyPageData: storyPageData, bookDataPath: bookDataPath, book:book, activePage: activePage + 1,
                                    ttsManager:ttsManager, readingLevel: readingLevel
                                ), isActive: $navigateToNextPage
                            )
                            {
                                EmptyView()
                            }
                            Image("right")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width : 100, height : 100)
                                .onTapGesture(perform: {
                                    cancelScheduledTextToSpeech()
                                    if currentCorrectWords.count > 0{
                                        ttsManager.totalAcquiredPoints += currentCorrectWords.count
                                    }
                                    print(ttsManager.totalAcquiredPoints)
                                    navigateToNextPage = true
                                })
                        }
                        else {
                            NavigationLink(
                                destination: PlacementTestResultView(book: book, readingLevel: readingLevel, testResultMsg: testResultMsg),
                                isActive: $navigateToNextScreen
                            ){
                                EmptyView()
                            }
                            Image("right")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width : 100, height : 100)
                                .onTapGesture(perform: {
                                    print(ttsManager.totalAcquiredPoints)
                                    sendPlacementTestResult()
                                    cancelScheduledTextToSpeech()
                                })
                        }
                    }
                    Spacer()
                }
                
                ZStack{
                    VStack{
                        Spacer()
                        
                        if ttsManager.finishSpeak {
                            HStack(alignment: .bottom){
                                Button(action: {
                                    // TODO: stop and play separate text to speech (always stop it whenever its changing page)
                                    
                                }) {
                                    Image("speaker")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height:50, alignment: .center)
                                        .background(.white)
                                }
                                .frame(width: 70, height:70, alignment: .center)
                                .background(.white)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                                
                                if ttsManager.storyLines.count > 0 {
                                    HStack(alignment: .center){
                                        let storyText : NSAttributedString = NSAttributedString(string: ttsManager.storyLines[recordingLine])
                                        //let storyText : NSAttributedString = NSAttributedString(string: testingLines[recordingLine])
                                        
                                        if let resultLabel = speechResultLabel{
                                            StrokeTextFull(text: resultLabel.string, textWithAttribute: AttributedString(resultLabel), width: 2.5, color: .white)
                                                .foregroundColor(.black)
                                                .font(.custom("Poppins-Medium", size: 26))
                                        }
                                        else{
                                            StrokeTextFull(text: storyText.string, textWithAttribute: AttributedString(storyText), width: 2.5, color: .white)
                                                .foregroundColor(.black)
                                                .font(.custom("Poppins-Medium", size: 26))
                                        }
                                    }
                                    .frame(minHeight: 70)
                                    .padding(.horizontal, 15)
                                }
                                
                                Button(action: {
                                    // TODO: play start and stop record sfx
                                    isStartRecording = !isStartRecording
                                    if isStartRecording{
                                        startSpeechRecognition()
                                    }
                                    else{
                                        cancelSpeechRecognition()
                                    }
                                }) {
                                    Image(isStartRecording ? "record_active" : "record")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 67, height:67, alignment: .center)
                                        .padding(2)
                                        .padding(.leading, 3.5)
                                        .padding(.bottom, 1)
                                        .background(.white)
                                        .clipShape(Circle())
                                        .clipped()
                                        .shadow(radius: 10)
                                }
                            }
                            .frame(alignment: .trailing)
                            .padding()
                            .background(.white)
                        }
                    }
                    .frame(alignment: .trailing)
                    
                }
            }
            .edgesIgnoringSafeArea(.all)
            .toolbar(.hidden, for: .tabBar)
            .onAppear {
                ttsManager.finishSpeak = false
                forceLandscapeOrientation()
                StartTextToSpeech()
            }
            .onDisappear{}
        }
        .navigationBarBackButtonHidden(true)
    }
}
