//
//  TestView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 30/09/23.
//

import SwiftUI
import AVFoundation
import Speech

struct TestView : View {
    let activePage : Int
    
    @ObservedObject var ttsManager = TextToSpeechManager()
    @State private var storyPageData: StoryPageData?
    @Environment(\.presentationMode) var presentationMode
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    @State private var task : SFSpeechRecognitionTask!
    @State private var isStart : Bool = false
    @State private var enableSpeak : Bool = false
    @State private var speechResultText : String = ""
    @State private var currentTextLine : Int = 0
    @State private var isTextToSpeechActive : Bool = false
        
    func requestSpeechPermission(){
        SFSpeechRecognizer.requestAuthorization{ (authState) in
            OperationQueue.main.addOperation {
                if authState == .authorized{
                    enableSpeak = true
                    //print("Speech Recognition is autorized")
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
            speechResultText = message
            print(message)
        })
    }

    func cancelSpeechRecognition(){
        task.finish()
        task.cancel()
        task = nil
        
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    
//    init(storyPageData: StoryPageData, bookDataPath: String) {
//        self.storyPageData = storyPageData
//        self.bookDataPath = bookDataPath
//        requestSpeechPermission()
//    }
    
    init(activePage: Int, ttsManager: TextToSpeechManager){
        self.activePage = activePage
        self.ttsManager = ttsManager
        requestSpeechPermission()
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                
                HStack {
                    GeometryReader { geometry in
//                        AsyncImage(url: URL(string: bookDataPath + storyPageData.pages[activePage].imgUrl)) { phase in
                        if let storyPageData = storyPageData{
                            AsyncImage(url: URL(string: "https://avntestbucket01.s3.ap-northeast-1.amazonaws.com/public/document/646a69a434c9f/" + storyPageData.pages[activePage].imgUrl)) { phase in
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
                    }
                    .edgesIgnoringSafeArea(.all)
                }
                
                
                
                GeometryReader { geometry in
                    ZStack {
                        if let storyPageData = storyPageData, storyPageData.pages[activePage].lines.count > 0{
                            ForEach(storyPageData.pages[activePage].lines.indices, id: \.self) { index in
                                let line = storyPageData.pages[activePage].lines[index]
                                let left =  (line.left *  geometry.size.width/storyPageData.pages[activePage].width)
                                let top = CGFloat(line.top  *  geometry.size.height/storyPageData.pages[activePage].height) - geometry.size.height/2
                                let topMargin = top * 2
                                let finalTopMargin = topMargin - line.fontSize/2 <= -(geometry.size.height/2) ? topMargin + line.lineHeight/4 : topMargin
                                
                                let text : NSAttributedString = NSAttributedString(string: line.text)
                                
                                // check if its one of text is out of area of bottom, each text need to be add some space of top
                                if let speakerLabel = ttsManager.label{
                                    if line.text == speakerLabel.string{
                                        LabelRepresented(text: ttsManager.label, customFontSize: CGFloat(line.fontSize * geometry.size.height/storyPageData.pages[activePage].height), padding: UIEdgeInsets(top: finalTopMargin, left: left, bottom: 0, right: 0))
                                    }
                                    else{
                                        LabelRepresented(text: text, customFontSize: CGFloat(line.fontSize * geometry.size.height/storyPageData.pages[activePage].height), padding: UIEdgeInsets(top: finalTopMargin, left: left, bottom: 0, right: 0))
                                    }
                                }
                                else{
                                        LabelRepresented(text: text, customFontSize: CGFloat(line.fontSize * geometry.size.height/storyPageData.pages[activePage].height), padding: UIEdgeInsets(top: finalTopMargin, left: left, bottom: 0, right: 0))
                                }
                                
                            }
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                }
                
                
                
                VStack {
                    HStack {                        
                        NavigationLink(destination: TestView(activePage: activePage - 1, ttsManager:ttsManager)){
                                Image(systemName: "arrow.left")
                                    .font(.title)
                                    .padding()
                        }
                        .onTapGesture(perform: {
                            presentationMode.wrappedValue.dismiss()
//                            ttsManager.reset(storyPageData.pages[activePage - 1].lines)
                        })
                        
                        Spacer()
                        
                        NavigationLink(destination: TestView(activePage: activePage + 1, ttsManager:ttsManager)){
                                Image(systemName: "arrow.right")
                                    .font(.title)
                                    .padding()
                        }
                        .onTapGesture(perform: {
//                            ttsManager.reset(storyPageData.pages[activePage + 1].lines)
                        })
                    }
                    Spacer()
                }
                
                if ttsManager.finishSpeak {
                    VStack{
                        Spacer()
                        
                        HStack{
                            Button(action: {
                                isStart = !isStart
                                if isStart{
                                    startSpeechRecognition()
                                }
                                else{
                                    cancelSpeechRecognition()
                                }
                            }) {
                                Text(isStart ? "STOP" : "START")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(isStart ? Color.blue : Color.black)
                                    .cornerRadius(10)
                            }
                            
                            Text(speechResultText)
                                .padding()
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                }
                
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                ttsManager.finishSpeak = false
                forceLandscapeOrientation()
                fetchDataFromAPI()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func fetchDataFromAPI() {
        guard let url = URL(string: "http://dinoreaders.com/api/dashboard/latestfive") else {
            return
        }
            
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
                
        URLSession.shared.dataTask(with: request) { data, response, error in
            let jsonURLString = "https://avntestbucket01.s3.ap-northeast-1.amazonaws.com/public/document/646a69a434c9f/book_data.json"

            if let url = URL(string: jsonURLString) {
                fetchStoryPageData(from: url) { result in
                    switch result {
                    case .success(let bookData):
                        storyPageData = bookData
                        if let storyPageData = storyPageData{
                            if storyPageData.pages[activePage].lines.count > 0{
                                ttsManager.speak(storyPageData.pages[activePage].lines)
                            }
                        }
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
            } else {
                print("Invalid URL")
            }
            
        }.resume()
    }
}
