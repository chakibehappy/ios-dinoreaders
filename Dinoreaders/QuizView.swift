import SwiftUI
import AVFoundation

struct Choice : Codable{
    var text : String
    var imageUrl : String
    
    init(text: String = "", imageUrl: String = "") {
        self.text = text
        self.imageUrl = imageUrl
    }
}

struct QuizView: View {
    
    let quizData : QuizData
    let bookId: Int
    
    @State private var isResultVisible = false
    
    @State private var playerAnswerIsCorrect = false
    
    @State private var isMultipleChoice = false
    
    @State private var showJumbleWords = false
    @State private var targetWord = "medicine"
    @State private var jumbleLetters : [String] = []
    @State private var jumbleBoxIsClicked : [Bool] = []
    @State private var jumbleBoxOnAnswerIndex : [Int] = []
    @State private var jumbleLetterAnswer : [Int] = []
    
    @State private var jumbleBoxOriPos : [CGSize] = []
    @State private var jumbleBoxTargetPos : [CGSize] = []
    @State private var jumbleBoxCurrentPos : [CGSize] = []
    @State private var answerBoxIndex = 0
    @State private var yTarget = CGFloat(0)
    @State private var paddingY = CGFloat(8)
    @State private var canClickBox = true
    @State private var delayJumbleQuizCheck = 1000
    
    @State private var currentQuizIndex = 0
    
    private var readingPointForQuiz = 10
    private var bonusForAllCorrectAnswer = 10
    @State private var correctAnswerCount = 0
    
    @State private var questionText = "Who is the girl with the crying face?"
    @State private var quizQuestionImage = ""
    @State private var correctChoiceAnswer = ""
    @State private var correctChoiceAnswerImage = ""
    @State private var correctChoice : Choice = Choice()
    @State private var multipleChoice : [Choice] = []
    let delimiter = "<-@->"
    
    @State var playQuestionAudio = false
    let synth = AVSpeechSynthesizer()
    
    
    @State private var navigateToDinoEggScreen: Bool = false
    @State private var dinoEggs : [DinoEgg] = []
    @State private var backToSingleBookView = false
    
    init(quizData:QuizData, bookId: Int){
        self.quizData = quizData
        self.bookId = bookId
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("quiz_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(alignment: .center) {
                    GeometryReader { geometry in
                        VStack(alignment: .center) {
                            HStack(alignment: .center) {
                                Text("x")
                                    .font(.custom("Poppins-SemiBold", size: 28))
                                    .frame(width: 50, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10).fill(Color.white)
                                    )
                                    .overlay(
                                        GeometryReader { geo in
                                            Color.clear
                                                .onAppear {
                                                    // Use async to ensure view layout is complete
                                                    DispatchQueue.main.async {
                                                        // Ensure the layout has settled
                                                        yTarget = geo.frame(in: .global).midY
                                                        //print("yTarget:", yTarget)
                                                        //print("height:", geometry.size.height)
                                                    }
                                                }
                                                .onChange(of: geometry.size) { _ in
                                                    // Respond to size changes due to orientation
                                                    DispatchQueue.main.async {
                                                        yTarget = geo.frame(in: .global).midY
                                                        //print("Updated yTarget:", yTarget)
                                                        //print("height:", geometry.size.height)
                                                    }
                                                }
                                        }
                                    )
                                    .opacity(0)
                            }
                            .frame(width: geometry.size.width)
                        }
                        .frame(height: geometry.size.height/2)
                        Spacer()
                    }
                }
                .ignoresSafeArea()
                
                if isMultipleChoice {
                    VStack {
                        GeometryReader { geometry in
                            VStack(alignment: .center) {
                                HStack(alignment: .center) {
                                    StrokeText(text: questionText, width: 2.5, color: .white)
                                        .font(.custom("Ruddy-Bold", size: 18))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                    
                                    if quizQuestionImage != "" {
                                        AsyncImage(url: URL(string: quizQuestionImage)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1.5).foregroundColor(.black))
                                            case .failure(let error):
                                                Text("Error: \(error.localizedDescription)")
                                            @unknown default:
                                                Text("Unknown state")
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 90)
                                .padding(.vertical, 20)
                                .padding(.trailing, 15)
                                .frame(height: geometry.size.height/2)
                                
                                VStack (alignment: .center){
                                    HStack {
                                        if multipleChoice.count >= 1 {
                                            Button(action:{ CheckMultipleChoiceAnswer(selectedChoice: multipleChoice[0]) }){
                                                AnswerView(choice: multipleChoice[0])
                                            }
                                        }
                                        if multipleChoice.count >= 2 {
                                            Button(action:{ CheckMultipleChoiceAnswer(selectedChoice: multipleChoice[1]) }){
                                                AnswerView(choice: multipleChoice[1])
                                            }
                                        }
                                    }
                                    if multipleChoice.count > 2 {
                                        HStack {
                                            if multipleChoice.count >= 3 {
                                                Button(action:{ CheckMultipleChoiceAnswer(selectedChoice: multipleChoice[2]) }){
                                                    AnswerView(choice: multipleChoice[2])
                                                }
                                            }
                                            if multipleChoice.count >= 4 {
                                                Button(action:{ CheckMultipleChoiceAnswer(selectedChoice: multipleChoice[3]) }){
                                                    AnswerView(choice: multipleChoice[3])
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, 40)
                                .padding(.horizontal, 50)
                                .frame(height: geometry.size.height/2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                }
                else {
                    if showJumbleWords {
                        VStack {
                            GeometryReader { geometry in
                                VStack( alignment: .center){
                                    HStack(alignment: .center) {
                                        ForEach(0..<jumbleLetterAnswer.count, id: \.self) { index in
                                            Text("")
                                                .font(.custom("Poppins-SemiBold", size: 28))
                                                .frame(width: 50, height: 50)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color.white)
                                                )
                                                .overlay(
                                                    GeometryReader{ geo -> AnyView in
                                                        AnyView(Color.clear
                                                            .onAppear(){
                                                                jumbleBoxTargetPos[index] = CGSize(width: geo.frame(in: .global).midX, height: geo.frame(in: .global).midY)
                                                            })
                                                    }
                                                )
                                        }
                                    }
                                    .frame(width: geometry.size.width, height: geometry.size.height/2)
                                    
                                    HStack (alignment: .center){
                                        ForEach(0..<jumbleLetters.count, id: \.self) { index in
                                            StrokeText(text: jumbleLetters[index], width: 1.5, color: .white)
                                                .foregroundColor(.black)
                                                .font(.custom("Poppins-SemiBold", size: 28))
                                                .frame(width: 50, height: 50)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color.yellow)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .stroke(Color.black, lineWidth: 1.5)
                                                        )
                                                )
                                                .offset(jumbleBoxCurrentPos[index])
                                                .animation(.spring(), value: jumbleBoxCurrentPos[index])
                                                .onTapGesture {
                                                    if !canClickBox{
                                                        return
                                                    }
                                                    if !jumbleBoxIsClicked[index] {
                                                        jumbleBoxIsClicked[index] = true
                                                        jumbleBoxCurrentPos[index] = CGSize(width: jumbleBoxTargetPos[answerBoxIndex].width - jumbleBoxOriPos[index].width, height: yTarget  - jumbleBoxOriPos[index].height)
                                                        jumbleBoxOnAnswerIndex[index] = answerBoxIndex
                                                        jumbleLetterAnswer[answerBoxIndex] = index
                                                        answerBoxIndex += 1
                                                        
                                                        if answerBoxIndex == jumbleLetters.count {
                                                            canClickBox = false
                                                            let delay = DispatchTimeInterval.milliseconds(Int(delayJumbleQuizCheck))
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                                                CheckJumbleWordsAnswer()
                                                            }
                                                        }
                                                    }
                                                    else{
                                                        jumbleBoxIsClicked[index] = false
                                                        jumbleBoxCurrentPos[index] = CGSize(width: 0, height: 0)
                                                        replaceAndShiftLeft(at: jumbleBoxOnAnswerIndex[index], in: &jumbleLetterAnswer)
                                                        
                                                        answerBoxIndex -= 1
                                                        
                                                        var i = 0
                                                        for boxIndex in jumbleLetterAnswer {
                                                            if boxIndex >= 0 {
                                                                jumbleBoxIsClicked[boxIndex] = true
                                                                jumbleBoxCurrentPos[boxIndex] = CGSize(width: jumbleBoxTargetPos[i].width - jumbleBoxOriPos[boxIndex].width, height: yTarget - jumbleBoxOriPos[boxIndex].height)
                                                                jumbleBoxOnAnswerIndex[boxIndex] = i
                                                                i += 1
                                                            }
                                                        }
                                                    }
                                                }
                                                .overlay(
                                                    GeometryReader{ geo -> AnyView in
                                                        AnyView(Color.clear
                                                            .onAppear(){
                                                                print("box:", geo.frame(in: .global).midX , geo.frame(in: .global).midY)
                                                                jumbleBoxOriPos[index] = CGSize(width: geo.frame(in: .global).midX, height: geo.frame(in: .global).midY)
                                                            })
                                                    }
                                                )
                                        }
                                    }
                                    .frame(height: geometry.size.height/2)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight:.infinity)
                    }
                }
                
                VStack {
                    HStack {
                        NavigationLink(
                            //destination: SingleBookView(book_id:bookId),
                            destination: HomeTabView(),
                            isActive: $backToSingleBookView
                        ){
                            EmptyView()
                        }
                        NavigationLink(
                            destination: DinoEggsInfoView(dinoEggs: dinoEggs),
                            isActive: $navigateToDinoEggScreen
                        ){
                            EmptyView()
                        }
                        Image("close_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipped()
                            .onTapGesture(perform: {
                                forcePortraitOrientation()
                                backToSingleBookView = true
                            })
                        
                        Spacer()
                        if playQuestionAudio {
                            Button(action: {
                                synth.stopSpeaking(at: .immediate)
                                //print (AVSpeechSynthesisVoice.speechVoices())
                                let utterance = AVSpeechUtterance(string: questionText)
                                utterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
                                utterance.rate = 0.45
                                synth.speak(utterance)
                            }){
                                Image("speaker")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipped()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.white)
                                    )
                            }
                        }
                    }
                    .padding(.all, 20)
                    .padding(.horizontal, 15)
                    Spacer()
                }
                
                
                if isResultVisible {
                    ZStack {
                        Color.black.opacity(0.45)
                            .edgesIgnoringSafeArea(.all)

                        VStack(alignment: .center, spacing: 0) {
                            HStack(alignment: .center){
                                StrokeText(text: playerAnswerIsCorrect ? "Your Answer is\nCorrect!" :  "Your Answer is\nWrong!", width: 2.5, color: .white)
                                    .font(.custom("Ruddy-Bold", size: 22))
                                    .foregroundColor(.black)
                                    .padding(.top, 30)
                                    .padding(.horizontal, 20)
                                    .multilineTextAlignment(.center)
                            }

                            Button(action: {
                                isResultVisible = false
                                InitQuiz()
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
                        .background(playerAnswerIsCorrect ? .yellow : .red)
                        .cornerRadius(15)
                        .padding()
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .toolbar(.hidden, for: .tabBar)
            .onAppear {
                forceLandscapeOrientation()
                InitQuiz()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    func replaceAndShiftLeft(at index: Int, in array: inout [Int]) {
        if index >= 0 && index < array.count {
            for i in index..<array.count - 1 {
                array[i] = array[i + 1]
            }
            array[array.count - 1] = -1
        }
    }

    
    func InitQuiz(){
        if currentQuizIndex < quizData.quiz.count {
            playerAnswerIsCorrect = false
            let quiz : Quiz = quizData.quiz[currentQuizIndex]
            isMultipleChoice = quiz.quiz_type == "Multiple Choice"
            playQuestionAudio = quiz.use_question_audio == 1
            if let quizQuestion = quiz.question {
                questionText = quizQuestion
            }
            
            if (isMultipleChoice)
            {
                if let questionImage = quiz.question_img_url {
                    quizQuestionImage = questionImage
                }
                correctChoiceAnswer = ""
                if let correctAnswer = quiz.right_answer {
                    correctChoiceAnswer = correctAnswer
                }
                correctChoiceAnswerImage = ""
                if let correctAnswerImage = quiz.right_answer_img_url {
                    correctChoiceAnswerImage = correctAnswerImage
                }
                
                multipleChoice = []
                
                correctChoice = Choice(text:correctChoiceAnswer, imageUrl: correctChoiceAnswerImage)
                multipleChoice.append(correctChoice)

                var wrongChoicesText : [String] = []
                var wrongChoicesImage : [String] = []
                
                if let wrongAnswer = quiz.wrong_answer {
                    let choices = wrongAnswer.components(separatedBy: delimiter)
                    for choice in choices {
                        wrongChoicesText.append(choice)
                    }
                }
                if let wrongAnswerImg = quiz.wrong_answer_img_url {
                    let images = wrongAnswerImg.components(separatedBy: delimiter)
                    for img in images {
                        wrongChoicesImage.append(img)
                    }
                }
                
                if wrongChoicesText.count > 0 {
                    if wrongChoicesImage.count > 0 {
                        var i = 0
                        for choice in wrongChoicesText {
                            multipleChoice.append(Choice(text:choice, imageUrl: wrongChoicesImage[i]))
                            i += 1
                        }
                    }
                    else
                    {
                        for choice in wrongChoicesText {
                            multipleChoice.append(Choice(text:choice, imageUrl: ""))
                        }
                    }
                } else {
                    for img in wrongChoicesImage {
                        multipleChoice.append(Choice(text:"", imageUrl: img))
                    }
                }
                
                multipleChoice.shuffle()
            }
            else
            {
                canClickBox = true
                if let quizQuestion = quiz.question {
                    targetWord = quizQuestion
                }
                //print(targetWord)
                answerBoxIndex = 0
                jumbleLetters = Array(targetWord.uppercased()).map { String($0) }
                jumbleLetters.shuffle()
                
                jumbleLetterAnswer = Array(repeating: -1, count: jumbleLetters.count)
                jumbleBoxOnAnswerIndex = Array(repeating: -1, count: jumbleLetters.count)
                jumbleBoxIsClicked = Array(repeating:false, count: jumbleLetters.count)
                jumbleBoxOriPos = Array(repeating:CGSize(width: 0, height: 0), count: jumbleLetters.count)
                jumbleBoxCurrentPos = Array(repeating:CGSize(width: 0, height: 0), count: jumbleLetters.count)
                jumbleBoxTargetPos = Array(repeating:CGSize(width: 0, height: 0), count: jumbleLetters.count)
                showJumbleWords = true
            }
        }
        else {
            //testCheckDinoEggData()
            checkDinoEggData()
        }
    }
    
    func CheckMultipleChoiceAnswer(selectedChoice : Choice){
        if((selectedChoice.text == correctChoice.text && correctChoice.text != "") ||
           (selectedChoice.imageUrl == correctChoice.imageUrl && correctChoice.imageUrl != "")){
            playerAnswerIsCorrect = true
        }else{
            playerAnswerIsCorrect = false
        }
        SendQuizResult()
    }
    
    func CheckJumbleWordsAnswer(){
        var answer = ""
        for box in jumbleLetterAnswer{
            answer += jumbleLetters[box]
        }
        if(answer.lowercased() == targetWord.lowercased()){
            playerAnswerIsCorrect = true
        }else{
            playerAnswerIsCorrect = false
        }
        showJumbleWords = false
        SendQuizResult()
    }
    
    func SendQuizResult()
    {
        var point = 0
        if playerAnswerIsCorrect == true{
            point += readingPointForQuiz;
            correctAnswerCount += 1
        }
        if correctAnswerCount >= quizData.quiz.count {
            point += bonusForAllCorrectAnswer;
        }
        
        if point == 0 {
            ShowResultScreen()
        }
        else {
            let url = URL(string: API.SAVEREADINGHISTORY_API)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")

            let requestBody: [String: Any] = [
                "user_id": UserDefaultManager.UserID,
                "profile_id": UserDefaultManager.ProfileID,
                "book_id": bookId,
                "reading_count": 0,
                "reading_time": 0,
                "reading_score": point
            ]

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
                if let data = data {
                    ShowResultScreen()
                } else {
                    print("Reading history saved successfully, but failed to decode response data")
                    ShowResultScreen()
                }
            }
            task.resume()
        }
    }
    
    func ShowResultScreen(){
        isResultVisible = true
        currentQuizIndex += 1
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
                let delay = DispatchTimeInterval.milliseconds(Int(1000))
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    if getDinoEgg {
                        navigateToDinoEggScreen = true
                    } else {
                        backToSingleBookView = true
                    }
                    forcePortraitOrientation()
                }
            } catch {
                print("Error decoding Dino Eggs Obtain data JSON: \(error)")
                DispatchQueue.main.async {
                    forcePortraitOrientation()
                    backToSingleBookView = true
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
                    let delay = DispatchTimeInterval.milliseconds(Int(1000))
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        forcePortraitOrientation()
                        if getDinoEgg {
                            navigateToDinoEggScreen = true
                        } else {
                            backToSingleBookView = true
                        }
                    }
                } catch {
                    print("Error decoding Dino Eggs Obtain data JSON: \(error)")
                    DispatchQueue.main.async {
                        forcePortraitOrientation()
                        backToSingleBookView = true
                    }
                }
            }
        }.resume()
    }
}

struct AnswerView: View {
    var choice: Choice

    var body: some View {
        HStack {
            StrokeText(text:choice.text, width: 2.5, color: .white)
                .font(.custom("Ruddy-Bold", size: 18))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            
            if choice.imageUrl != "" {
                AsyncImage(url: URL(string: choice.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 1).foregroundColor(.gray))
                            .padding(7)
                    case .failure(let error):
                        Text("Error: \(error.localizedDescription)")
                    @unknown default:
                        Text("Unknown state")
                    }
                }
            }
        }
        .frame(maxHeight: 100)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor(red: 0.8, green: 0.85, blue: 1.0, alpha: 1.0)))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 1.5)
                )
        )
        .padding(.all, 4)

    }
}


struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(quizData: QuizData(), bookId: 0)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
