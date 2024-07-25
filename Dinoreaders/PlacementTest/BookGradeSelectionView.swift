import SwiftUI

struct BookGradeSelectionView: View {
    
    let reading_level : String
    @State var gradeBooks : [GradeBook] = []
    @State private var storyPageData: StoryPageData? = nil
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isLoading: Bool = false
    
    func getBookDataByLevel(){
        guard let url = URL(string: API.GETBOOKBYREADINGLEVEL_API + reading_level) else {
            return
        }
            
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
                
        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data {
//                let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
//                if let fullResponse = jsonResponse as? [String : Any]{
//                    print(fullResponse)
//                }
//            }
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(GradeBookData.self, from: data)
                    if(decodedData.success == true){
                        DispatchQueue.main.async {
                            self.gradeBooks = decodedData.data
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }

    
    var body: some View {
        NavigationStack{
            ZStack{
                VStack(alignment: .leading) {
                    HStack(alignment: .center){
                        Button( action: { self.presentationMode.wrappedValue.dismiss()})
                        {
                            Image("back_arrow_new")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .scaledToFill()
                                .clipped()
                        }
                        VStack (alignment: .leading){
                            Text("Select The Book")
                                .font(.custom("Poppins-Black", size: 20))
                                .shadow(color: Color.blue, radius: 30)
                                .foregroundColor(.white)
                            if let level = Int(reading_level) {
                                Text(GradeLabel.gradeName(at: level - 1) + " Reader")
                                    .font(.custom("Quicksand-Bold", size: 14))
                                    .foregroundColor(Color(hex: "#FFECB3"))
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                    .padding(.top, 25)
                    .padding(.horizontal, 8)
                    .padding(.leading, 40)
                    .padding(.bottom, 10)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(gradeBooks, id: \.id){ book in
                                if let readingLevel = Int(reading_level) {
                                    BookCardView(isLoading:$isLoading, book:book, readingLevel: readingLevel)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.leading, 30)
                    Spacer()
                }
                .background(Color(hex:"#35A8E7"))
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .tabBar)
                .onAppear(){
                    getBookDataByLevel()
                    forceLandscapeOrientation()
                }
                
                if isLoading {
                    Button(action:{
                       isLoading = false
                    }){
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            )
                    }
                }
            }
        }
        
    }
}

struct BookCardView: View {
    @Binding var isLoading: Bool
    let book: GradeBook
    let readingLevel: Int
    @State var singleBook : SingleBook?
    @State var storyPageData : StoryPageData?
    @State var goToStoryScreen = false
    
    func getBookDetail(){
        guard let url = URL(string: API.GETBOOKDETAIL_API + String(book.id)) else {
            return
        }
        isLoading = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
                
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("Response JSON string: \(jsonString)")
//                }
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(SingleBookData.self, from: data)
                    singleBook = result.data
                    if let singleBook = singleBook {
                        let jsonURLString = API.AWS_PATH + "/public/document/" + book.uid + "/book_data.json"
                        if let url = URL(string: jsonURLString) {
                            fetchStoryPageData(from: url) { result in
                                switch result {
                                case .success(let bookData):
                                    // Filtering pages based on show_pages and play_audio
                                    let filteredPages = singleBook.pages.filter { $0.show_pages == 1 }
                                    let pageNumbers = filteredPages.map { $0.page_number }
                                    let filteredStoryPages = bookData.pages.filter { pageNumbers.contains($0.pageNumber) }.map { page in
                                        let isStoryPage = true // or any logic to determine its value
                                        let playAudio = filteredPages.first(where: { $0.page_number == page.pageNumber })?.play_audio == 1
                                        return Page(
                                            pageNumber: page.pageNumber,
                                            imgUrl: page.imgUrl,
                                            width: page.width,
                                            height: page.height,
                                            fontSpace: page.fontSpace,
                                            lines: page.lines,
                                            isStoryPage: isStoryPage,
                                            playAudio: playAudio,
                                            fullText: ""
                                        )
                                    }
                                    
                                    let currentPageData = StoryPageData(creator: bookData.creator, pages: filteredStoryPages)
                                    storyPageData = processPages(currentPageData)
                                    goToStoryScreen = true
                                case .failure(let error):
                                    print("Error: \(error)")
                                }
                            }
                        } else {
                            print("Invalid URL")
                        }
                    }
                    
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
    
    var body: some View {
        VStack {
            if let storyPageData = storyPageData {
                if let singleBook = singleBook {
                    NavigationLink(destination: PlacementTestReading(
                        storyPageData: storyPageData,
                        bookDataPath: API.AWS_PATH + "/public/document/" + book.uid + "/",
                        book : singleBook,
                        activePage: 0,
                        ttsManager: TextToSpeechManager(),
                        readingLevel: readingLevel
                    ), isActive: $goToStoryScreen){
                        EmptyView()
                    }
                }
            }
            AsyncImage(url: URL(string: book.image_url)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 120, height: 120)
                        .padding(.top,20)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.top,20)
                case .failure(let error):
                    Text("Error: \(error.localizedDescription)")
                @unknown default:
                    Text("Unknown state")
                }
            }
            
            Text(book.title)
                .font(.custom("Quicksand-Bold", size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .frame(width: 120, height: 85, alignment: .center)
                .lineLimit(5)
                .padding(.horizontal, 8)
        }
        .padding(.all, 5)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(radius: 5)
        .padding(6)
        .onTapGesture {
            getBookDetail()
        }
    }
}
