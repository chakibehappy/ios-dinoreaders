import Speech
import SwiftUI
import AVFoundation
import SwiftWhisper
import AVKit

struct StoryBookView: View {
    
    let storyPageData: StoryPageData
    let bookId: Int
    let bookDataPath: String
    let activePage : Int
    let quizData : QuizData
    let isReadToMe : Bool
    @ObservedObject var ttsManager = TextToSpeechManager()
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var readingTimeManager : ReadingTimeManager
    @EnvironmentObject var settings : UserSettings
    
    //@State var timer = ReadingTimeManager(isGlobal: false)
    
    // or can simply get time at first opening, and then reduce it from total time when its on last page!
    // but global timer is off if is_setting_time = false !?
    
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
    @State private var navigateToPrevPage: Bool = false
    @State private var navigateToPrevScreen: Bool = false
    @State private var navigateToNextScreen: Bool = false
    @State private var navigateToHomeScreen: Bool = false
    @State private var navigateToDinoEggScreen: Bool = false
    
    @State private var dinoEggs : [DinoEgg] = []
    @State private var startSpeakingWorkItem: DispatchWorkItem?

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
                            readingTimeManager.pauseTracking()
                            if activePage < storyPageData.pages.count - 1 {
                                navigateToNextPage = true
                            } else{
                                sendReadingProgress(bookCount: 1)
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
    
    func isReadingTimeOver() -> Bool{
        if !settings.ReadingSetting.set_limit_time{
            return false
        }
        let reading_time = Int(UserDefaults.standard.double(forKey: "totalTimeSpent"))
        return (settings.ReadingSetting.reading_time * 60) - reading_time <= 0
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
        
        if ttsManager.storyBookStart || activePage > 0 {
            ttsManager.playSound(audioFileName: "flip_page_2")
        }
        
        if !isReadToMe {
            return
        }
        
        ttsManager.finishSpeak = false
        ttsManager.countTotalWords(page: storyPageData.pages[activePage], pageIndex: activePage)
        
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
    
    func sendReadingProgress(bookCount: Int) {
        
        let url = URL(string: API.SAVEREADINGHISTORY_API)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")

        let reading_time = Int(readingTimeManager.totalTimeSpent) - ttsManager.startTime
        let requestBody: [String: Any] = [
            "user_id": UserDefaultManager.UserID,
            "profile_id": UserDefaultManager.ProfileID,
            "book_id": bookId,
            "reading_count": bookCount,
            "reading_time": reading_time,
            "reading_score": ttsManager.totalAcquiredPoints
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
                //print("Reading history saved successfully")
                //print("Response: \(responseString)")
                readingTimeManager.pauseTracking()
                if quizData.quiz.count > 0 {
                    navigateToNextScreen = true
                } else {
                    checkDinoEggData()
                    //testCheckDinoEggData()
                }
            } else {
                print("Reading history saved successfully, but failed to decode response data")
            }
        }
        task.resume()
    }
    
    func testCheckDinoEggData(){
        let jsonString = """
        {
          "success": true,
          "data": [
            {
              "egg": {
                "user_id": 34,
                "profile_id": 48,
                "dino_egg_counter_id": 40,
                "dino_egg_id": 3,
                "points": 0,
                "status": "egg",
                "image_url": "https://dinoreadersbucket.s3.ap-southeast-1.amazonaws.com/public/dino-eggs/6629e17356800/1714020723brachiosaurus_egg.png",
                "updated_at": "2024-07-24T17:34:55.000000Z",
                "created_at": "2024-07-24T17:34:55.000000Z",
                "id": 22
              },
              "dino_egg_data": {
                "id": 3,
                "dino_egg_setting_id": 4,
                "dino_name": "Brachiosaurus",
                "egg_image": "https://dinoreadersbucket.s3.ap-southeast-1.amazonaws.com/public/dino-eggs/6629e17356800/1714020723brachiosaurus_egg.png",
                "baby_dino_image": "https://dinoreadersbucket.s3.ap-southeast-1.amazonaws.com/public/dino-eggs/6629e17356800/1714020723brachiosaurus.png",
                "adult_dino_image": "https://dinoreadersbucket.s3.ap-southeast-1.amazonaws.com/public/dino-eggs/6629e17356800/1714020724reader_buddy_3.png",
                "created_at": "2024-04-25T05:26:28.000000Z",
                "updated_at": "2024-04-25T05:26:28.000000Z",
                "deleted_at": null,
                "created_by": null,
                "updated_by": null,
                "deleted_by": null
              }
            },
            {
              "egg": {
                "id": 19,
                "user_id": 34,
                "profile_id": 48,
                "dino_egg_counter_id": 38,
                "dino_egg_id": 2,
                "points": 373,
                "status": "adult",
                "image_url": "https://dinoreadersbucket.s3.ap-southeast-1.amazonaws.com/public/dino-eggs/6629993ae1c30/1714002235reader_buddy_1.png",
                "created_at": "2024-06-17T18:44:01.000000Z",
                "updated_at": "2024-07-24T17:34:55.000000Z",
                "deleted_at": null
              },
              "dino_egg_data": {
                "id": 2,
                "dino_egg_setting_id": 2,
                "dino_name": "T-Rex",
                "egg_image": "https://dinoreadersbucket.s3.ap-southeast-1.amazonaws.com/public/dino-eggs/6629993ae1c30/1714002235dino_egg_2.png",
                "baby_dino_image": "https://dinoreadersbucket.s3.ap-southeast-1.amazonaws.com/public/dino-eggs/6629993ae1c30/1714002235t_rex.png",
                "adult_dino_image": "https://dinoreadersbucket.s3.ap-southeast-1.amazonaws.com/public/dino-eggs/6629993ae1c30/1714002235reader_buddy_1.png",
                "created_at": "2024-04-25T05:26:28.000000Z",
                "updated_at": "2024-04-29T00:15:22.000000Z",
                "deleted_at": null,
                "created_by": null,
                "updated_by": null,
                "deleted_by": null
              }
            }
          ]
        }
        """
        if let jsonData = jsonString.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(DinoEggObtainData.self, from: jsonData)
                var getDinoEgg = false
                if result.success {
                    if result.data.count > 0 {
                        for itemData in result.data{
                            dinoEggs.append(
                                DinoEgg(
                                    id: itemData.egg.id,
                                    dino_egg_id: itemData.egg.dino_egg_id,
                                    name: itemData.dino_egg_data.dino_name,
                                    local_path: "",
                                    asset_name: "",
                                    image_url: itemData.egg.image_url,
                                    status: itemData.egg.status
                                ))
                        }
                        //print(dinoEggs)
                        getDinoEgg = true
                    }
                }
                DispatchQueue.main.async {
                    if getDinoEgg {
                        navigateToDinoEggScreen = true
                    } else {
                        navigateToNextScreen = true
                    }
                }
            } catch {
                print("Error decoding Dino Eggs Obtain data JSON: \(error)")
                DispatchQueue.main.async {
                    navigateToNextScreen = true
                }
            }
        }
    }
    func checkDinoEggData(){
        guard let url = URL(string: API.DINO_EGG_CHECK_URL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(DinoEggObtainData.self, from: data)
                    var getDinoEgg = false
                    if result.success {
                        if result.data.count > 0 {
                            for itemData in result.data{
                                dinoEggs.append(
                                    DinoEgg(
                                        id: itemData.egg.id,
                                        dino_egg_id: itemData.egg.dino_egg_id,
                                        name: itemData.dino_egg_data.dino_name,
                                        local_path: "",
                                        asset_name: "",
                                        image_url: itemData.egg.image_url,
                                        status: itemData.egg.status
                                    ))
                            }
                            //print(dinoEggs)
                            getDinoEgg = true
                        }
                    }
                    DispatchQueue.main.async {
                        if getDinoEgg {
                            navigateToDinoEggScreen = true
                        } else {
                            navigateToNextScreen = true
                        }
                    }
                } catch {
                    print("Error decoding Dino Eggs Obtain data JSON: \(error)")
                    DispatchQueue.main.async {
                        navigateToNextScreen = true
                    }
                }
            }
        }.resume()
    }

    
    init(storyPageData: StoryPageData, bookDataPath: String, bookId: Int, activePage: Int, ttsManager: TextToSpeechManager, quizData:QuizData, isReadToMe: Bool){
        self.storyPageData = storyPageData
        self.bookDataPath = bookDataPath
        self.bookId = bookId
        self.activePage = activePage
        self.ttsManager = ttsManager
        self.quizData = quizData
        self.isReadToMe = isReadToMe
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
                        if isReadToMe {
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
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottomLeading)
                }
                
                VStack {
                    HStack {
                        if activePage > 0 {
                            
//                            NavigationLink(destination: StoryBookView(storyPageData: storyPageData, bookDataPath: bookDataPath, bookId:bookId, activePage: activePage - 1, ttsManager:ttsManager, quizData: quizData), isActive: $navigateToPrevPage){
//                                EmptyView()
//                            }
                            Image("left")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width : 100, height : 100)
                                .onTapGesture(perform: {
                                    if isReadToMe {
                                        cancelScheduledTextToSpeech()
                                    }
                                    if currentCorrectWords.count > 0{
                                        ttsManager.totalAcquiredPoints += currentCorrectWords.count
                                    }
                                    //navigateToPrevPage = true
                                    readingTimeManager.pauseTracking()
                                    self.presentationMode.wrappedValue.dismiss()
                                })
                        }
                        else {
//                            NavigationLink(destination: SingleBookView(book_id:bookId), isActive: $navigateToPrevScreen){
//                                EmptyView()
//                            }
                            Image("left")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width : 100, height : 100)
                                .onTapGesture(perform: {
                                    if isReadToMe {
                                        cancelScheduledTextToSpeech()
                                    }
                                    //navigateToPrevScreen = true                                    
                                    readingTimeManager.pauseTracking()
                                    self.presentationMode.wrappedValue.dismiss()
                                    forcePortraitOrientation()
                                })
                        }
                        
                        Spacer()
                        
                        if activePage < storyPageData.pages.count - 1 {
                            NavigationLink(
                                destination: StoryBookView(
                                    storyPageData: storyPageData, bookDataPath: bookDataPath, bookId:bookId, activePage: activePage + 1,
                                    ttsManager:ttsManager, quizData: quizData, isReadToMe: isReadToMe
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
                                    if isReadToMe {
                                        cancelScheduledTextToSpeech()
                                        if currentCorrectWords.count > 0{
                                            ttsManager.totalAcquiredPoints += currentCorrectWords.count
                                        }
                                    }
                                    readingTimeManager.pauseTracking()
                                    navigateToNextPage = true
                                })
                        }
                        else {
                            NavigationLink(
                                destination: quizData.quiz.count > 0 ? AnyView(QuizView(quizData: quizData, bookId:bookId)) :  AnyView(SingleBookView(book_id:bookId)),
                                isActive: $navigateToNextScreen
                            ){
                                EmptyView()
                            }
                            NavigationLink(
                                destination: DinoEggsInfoView(dinoEggs: dinoEggs),
                                isActive: $navigateToDinoEggScreen
                            ){
                                EmptyView()
                            }
                            Image("right")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width : 100, height : 100)
                                .onTapGesture(perform: {
                                    sendReadingProgress(bookCount: 1)
                                    if isReadToMe {
                                        cancelScheduledTextToSpeech()
                                    }
                                    readingTimeManager.pauseTracking()
                                })
                        }
                    }
                    Spacer()
                }
                
                ZStack{
                    VStack{
                        Spacer()
                        HStack{
                            if ttsManager.finishSpeak && isReadToMe {
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
                                    Text(isStartRecording ? "STOP" : "REC.")
                                        .padding()
                                        .foregroundColor(isStartRecording ? Color.red : Color.white)
                                        .background(.black)
                                        .cornerRadius(10)
                                        .fontWeight(.bold)
                                }
                                .padding(.bottom, 20)
                                .padding(.leading, 30)
                                
                                Spacer()
                                
                                ZStack{
                                    
                                    VStack{
                                        HStack{
                                            Image("star")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                                .padding(.leading, 5)
                                            StrokeText(text: String(settings.TotalPoints + ttsManager.totalAcquiredPoints), width: 1.25, color: .black)
                                                .foregroundColor(.white)
                                                .font(.custom("Ruddy-Black", size: 14))
                                        }
                                        .frame(width: 90, height:36, alignment: .leading)
                                        .background(Color(hex:settings.AvatarBackground.color))
                                        .cornerRadius(18)
                                        .padding(.trailing, 50)
                                    }
                                    .frame(alignment: .center)
                                    
                                    Image(settings.AvatarIcon.asset_name)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .padding(.leading, 50)
                                }
                            }
                        }
                        .frame(alignment: .leading)
                    }
                    .frame(alignment: .trailing)
                    
                    
                    if ttsManager.finishSpeak && isReadToMe {
                        VStack{
                            Spacer()
                            if ttsManager.storyLines.count > 0 {
                                HStack{
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
                                .frame(alignment: .leading)
                            }
                        }
                        .frame(alignment: .leading)
                        .padding(.bottom, 20)
                        .padding(.leading, 120)
                        .padding(.trailing, 140)
                    }
                    
                    if isReadingTimeOver() {
                        ZStack {
                            Color.black.opacity(0.45)
                                .edgesIgnoringSafeArea(.all)

                            VStack(alignment: .center, spacing: 0) {
                                HStack(alignment: .center){
                                    StrokeText(text: "Your reading time is over!", width: 2.5, color: .white)
                                        .font(.custom("Ruddy-Bold", size: 22))
                                        .foregroundColor(.black)
                                        .padding(.top, 30)
                                        .padding(.horizontal, 20)
                                        .multilineTextAlignment(.center)
                                }
                                
                                NavigationLink(
                                    destination: HomeTabView(), isActive: $navigateToHomeScreen
                                )
                                {
                                    EmptyView()
                                }
                                Button(action: {
                                    forcePortraitOrientation()
                                    navigateToHomeScreen = true
                                }) {
                                    Text("Continue")
                                        .font(.custom("Ruddy-Bold", size: 22))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 20)
                                }
                                .background(Color.black)
                                .cornerRadius(15)
                                .padding(.vertical, 20)
                            }
                            .frame(width: 300)
                            .background(.yellow)
                            .cornerRadius(15)
                            .padding()
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .toolbar(.hidden, for: .tabBar)
            .onAppear {
                if ttsManager.startTime <= 0 && !ttsManager.storyBookStart {
                    ttsManager.startTime = Int(readingTimeManager.totalTimeSpent)
                }
                
                if !isReadingTimeOver(){
                    readingTimeManager.startTracking()
                    forceLandscapeOrientation()
                    StartTextToSpeech()
                }
            }
            .onDisappear{}
        }
        .navigationBarBackButtonHidden(true)
    }
}

class NavigationCoordinator: ObservableObject {
    @Published var activePage: Int = 0
    @Published var isActive: Bool = false
    
    func navigate(to page: Int) {
        activePage = page
        isActive = true
    }
}
