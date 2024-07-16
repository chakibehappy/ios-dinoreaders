import Speech
import SwiftUI
import AVFoundation
import SwiftWhisper

struct StoryBookView: View {
    
    let storyPageData: StoryPageData
    let bookId: Int
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
    
    
    init(storyPageData: StoryPageData, bookDataPath: String, bookId: Int, activePage: Int, ttsManager: TextToSpeechManager){
        self.storyPageData = storyPageData
        self.bookDataPath = bookDataPath
        self.bookId = bookId
        self.activePage = activePage
        self.ttsManager = ttsManager
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
                                // Regular expression pattern to match sentences ending with .?! and keep the delimiters
                                let pattern = "([^.!?]+[.!?])"
                                
                                // Use NSRegularExpression to find matches based on the pattern
                                let regex = try! NSRegularExpression(pattern: pattern, options: [])
                                let nsString = text as NSString
                                
                                let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
                                
                                // Extract the matching sentences and trim whitespace
                                let trimmedComponents = results.map {
                                    nsString.substring(with: $0.range).trimmingCharacters(in: .whitespacesAndNewlines)
                                }
                                if ttsManager.currentLine >= 0 && ttsManager.currentLine < trimmedComponents.count {
                                    let storyText : NSAttributedString = NSAttributedString(string: trimmedComponents[ttsManager.currentLine])
                                    
                                    // check if its one of text is out of area of bottom, each text need to be add some space of top
                                    if let speakerLabel = ttsManager.label{
                                        if trimmedComponents[ttsManager.currentLine] == speakerLabel.string{
                                            LabelRepresented(text: ttsManager.label, customFontSize: 28)
                                                .padding(.leading, 60).padding(.bottom, 20)
                                        }
                                        else{
                                            LabelRepresented(text: storyText, customFontSize: 28)
                                                .padding(.leading, 60).padding(.bottom, 20)
                                        }
                                    }
                                    else{
                                        LabelRepresented(text: storyText, customFontSize: 28)
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
                        if activePage > 0 {
                            NavigationLink(destination: StoryBookView(storyPageData: storyPageData, bookDataPath: bookDataPath, bookId:bookId, activePage: activePage - 1, ttsManager:ttsManager)){
                                Image(systemName: "arrow.left")
                                    .font(.title)
                                    .padding()
                            }
                            .onTapGesture(perform: {
                                presentationMode.wrappedValue.dismiss()
                                ttsManager.reset()
                            })
                        }
                        else {
                            NavigationLink(destination: SingleBookView(book_id:bookId)){
                                Image(systemName: "arrow.left")
                                    .font(.title)
                                    .padding()
                            }
                        }
                        
                        Spacer()
                        
                        NavigationLink(
                            destination: StoryBookView(
                                storyPageData: storyPageData, bookDataPath: bookDataPath, bookId:bookId, activePage: activePage + 1,
                                ttsManager:ttsManager
                            )
                        )
                        {
                            Image(systemName: "arrow.right")
                                .font(.title)
                                .padding()
                        }
                        .onTapGesture(perform: {
                            presentationMode.wrappedValue.dismiss()
                            ttsManager.reset()
                        })
                    }
                    Spacer()
                }
                
                ZStack{
                    VStack{
                        Spacer()
                        HStack{
                            if ttsManager.finishSpeak {
                                Button(action: {
                                    isStart = !isStart
                                    if isStart{
                                        startSpeechRecognition()
                                    }
                                    else{
                                        cancelSpeechRecognition()
                                    }
                                }) {
                                    Text(isStart ? "STOP" : "REC.")
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(isStart ? Color.blue : Color.black)
                                        .cornerRadius(10)
                                }
                                .padding(.bottom, 20)
                                .padding(.leading, 30)
                                
                            }
                            else{
                                
                                
                            }
                            Spacer()
                        }
                    }
                    
                    if ttsManager.finishSpeak {
                        let storyText : NSAttributedString = NSAttributedString(string: speechResultText)
                        LabelRepresented(text: storyText, customFontSize: 30)
                            .padding(.leading, 120).padding(.bottom, 20).padding(.trailing, 50)
                    }
                }
           
                
            }
            .edgesIgnoringSafeArea(.all)
            .toolbar(.hidden, for: .tabBar)
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
            if let playAudio = storyPageData.pages[activePage].playAudio, playAudio {
                if storyPageData.pages[activePage].lines.count > 0 {
                    if let text = storyPageData.pages[activePage].fullText{
                        // Regular expression pattern to match sentences ending with .?! and keep the delimiters
                        let pattern = "([^.!?]+[.!?])"

                        // Use NSRegularExpression to find matches based on the pattern
                        let regex = try! NSRegularExpression(pattern: pattern, options: [])
                        let nsString = text as NSString

                        let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

                        // Extract the matching sentences and trim whitespace
                        let trimmedComponents = results.map {
                            nsString.substring(with: $0.range).trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            ttsManager.speak(trimmedComponents)
                            isHighlightingLine = true
                        }
                    }
                }
            }
        }
    }
}

struct LabelRepresented: UIViewRepresentable {
    var text: NSAttributedString?
    
    // Define custom font size
    var customFontSize: CGFloat = 28.0
    
    // Define stroke width and color
    var strokeWidth: CGFloat = 4.0  // Increased stroke width for better visibility
    var strokeColor: UIColor = .white  // Stroke color set to white
    
    func makeUIView(context: Context) -> UIView {
        // Create a container view with padding
        let containerView = UIView()
        
        let customFontName: String = "Poppins-SemiBold"
        
        // Create the UILabel
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the custom font size and font
        label.font = UIFont(name: customFontName, size: customFontSize)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0 // Allow multiple lines
        label.lineBreakMode = .byWordWrapping // Word wrapping for multiline support
            
        applyStroke(to: label)
        
        containerView.addSubview(label)
        
        // Apply constraints to the UILabel to respect padding
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let label = uiView.subviews.first as? UILabel else { return }
        
        // Update attributed text if provided
        if let attributedText = text {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            label.attributedText = mutableAttributedText
            	
            // Reapply stroke attributes
            applyStroke(to: label)
        }
    }
    
    private func applyStroke(to label: UILabel) {
        let strokeTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: strokeColor,
            .strokeWidth: -strokeWidth,
            .font: label.font ?? UIFont.systemFont(ofSize: customFontSize, weight: .bold)
        ]
        
        if let attributedText = label.attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedText.addAttributes(strokeTextAttributes, range: NSRange(location: 0, length: attributedText.length))
            label.attributedText = mutableAttributedText
        }
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
