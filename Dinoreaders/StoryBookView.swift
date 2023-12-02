import Speech
import SwiftUI
import AVFoundation


struct StoryBookView: View {
    
    let storyPageData: StoryPageData
    let bookDataPath: String
    let activePage : Int
    @ObservedObject var ttsManager = TextToSpeechManager()
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
    @State private var isHighlightingLine = false
    @State private var delayDuration = 1

    
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
    
    
    init(storyPageData: StoryPageData, bookDataPath: String, activePage: Int, ttsManager: TextToSpeechManager){
        self.storyPageData = storyPageData
        self.bookDataPath = bookDataPath
        self.activePage = activePage
        self.ttsManager = ttsManager
        requestSpeechPermission()
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                HStack {
                    GeometryReader { geometry in
                        AsyncImage(url: URL(string: bookDataPath + storyPageData.pages[activePage].imgUrl)) { phase in
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
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                }
                
                
                
                VStack {
                    HStack {
                        NavigationLink(destination: StoryBookView(storyPageData: storyPageData, bookDataPath: bookDataPath, activePage: activePage - 1, ttsManager:ttsManager)){
                                Image(systemName: "arrow.left")
                                    .font(.title)
                                    .padding()
                        }
                        .onTapGesture(perform: {
                            presentationMode.wrappedValue.dismiss()
                            ttsManager.reset()
                        })
                        
                        Spacer()
                        
                        NavigationLink(destination: StoryBookView(storyPageData: storyPageData, bookDataPath: bookDataPath, activePage: activePage + 1, ttsManager:ttsManager)){
                                Image(systemName: "arrow.right")
                                    .font(.title)
                                    .padding()
                        }
                        .onTapGesture(perform: {
                            ttsManager.reset()
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
                StartTextToSpeech()
            }
            .onDisappear{
                ttsManager.stopSpeaking()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func StartTextToSpeech() {
//        if(!ttsManager.finishSpeak){
//            ttsManager.stopSpeaking()
//        }
        
        let delay = DispatchTimeInterval.seconds(Int(delayDuration))
        if(!isHighlightingLine){
            
            if storyPageData.pages[activePage].lines.count > 0 && activePage > 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    ttsManager.speak(storyPageData.pages[activePage].lines)
                    isHighlightingLine = true
                }
            }
        }
    }
}

struct LabelRepresented: UIViewRepresentable {
    var text: NSAttributedString?

    // Define custom font size
    var customFontSize: CGFloat = 16.0

    // Define padding
    var padding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 0)

    func makeUIView(context: Context) -> UIView {
        // Create a container view with padding
        let containerView = UIView()

        // Create the UILabel
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        // Set the custom font size
        label.font = UIFont.systemFont(ofSize: customFontSize)

        // Add the UILabel to the container view
        containerView.addSubview(label)

        // Apply constraints to the UILabel to respect padding
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding.top),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding.left),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding.right),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding.bottom)
        ])

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let label = uiView.subviews.first as? UILabel {
            label.attributedText = text
        }
    }
}
