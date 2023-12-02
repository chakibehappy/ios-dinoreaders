//
//  SingleBookView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 21/09/23.
//

import SwiftUI

struct SingleBookView: View {
    
    let book: Book
    @State private var latestBooks: [Book] = []
    @State private var storyPageData: StoryPageData? = nil
    @State var showTabBar : Bool = false
    
    @Environment(\.presentationMode) var presentationMode

    let bgColor : Color = Color(red: 80/255, green: 120/255, blue: 1)
    let bottomColor : Color = Color(red: 64/255, green: 105/255, blue: 1)
    let pinkCol : Color = Color(red: 245/255, green: 153/255, blue: 158/255)

    var body: some View {
        
        NavigationStack{
            VStack(spacing: 0){
                ZStack{
                    HStack{
                        Button( action: { self.presentationMode.wrappedValue.dismiss()})
                        {
                            Image("back_arrow_new")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .scaledToFill()
                                .clipped()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                        }
                        Spacer()
                    }
                    
                    GeometryReader { geometry in
                        VStack{
                            Spacer()
                            Text(book.title)
                                .font(.custom("Ruddy-Bold", size: 32))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .frame(width: geometry.size.width - 105)
                        .padding(.horizontal, 70)
                    }
                }
                .frame(height: 65)
                .background(bgColor)
                
                ScrollView(.vertical, showsIndicators: false)
                {
                    VStack(spacing: 0){
                        ZStack{
                            AsyncImage( url: URL(string: book.image_url)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .clipped()
                                        .cornerRadius(5)
                                        .frame(height: 455)
                                case .failure(let error):
                                    Text("Error: \(error.localizedDescription)")
                                @unknown default:
                                    Text("Unknown state")
                                }
                            }
                            if let storyPageData = storyPageData {
                                
                                NavigationLink(destination: StoryBookView(
                                    storyPageData: storyPageData,
                                    bookDataPath: "https://avntestbucket01.s3.ap-northeast-1.amazonaws.com/public/document/" + book.uid + "/",
                                    activePage: 0, ttsManager: TextToSpeechManager()
                                )){
                                    Image("btn_begin")
                                        .resizable()
                                        .frame(width: 200, height: 60)
                                        .scaledToFill()
                                        .clipped()
                                        .padding(.top, 370)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 0){
                            VStack(alignment: .leading, spacing: 0){
                                HStack{
                                    VStack(spacing:0){
                                        Text("Author")
                                            .font(.custom("Ruddy-Bold", size: 24))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, alignment:.leading)
                                        Text(book.author)
                                            .font(.custom("Ruddy-Regular", size: 14))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, alignment:.leading)
                                    }
                                }
                                .padding(.bottom, 5)
                                Text("Reading level : \(book.reading_level)" )
                                    .font(.custom("Ruddy-Bold", size: 18))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment:.leading)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(bgColor)
                            .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 4)
                        
                            
                            HStack{
                                Text("More for you!")
                                    .foregroundColor(.white)
                                    .font(.custom("Ruddy-Black", size: 20))
                                    .padding(.horizontal, 13)
                                    .background(pinkCol)
                                    .cornerRadius(6.5)
                                    .underline(true, color: .white)
                                    .padding(.leading, 10)
                                    .padding(.bottom, 15)
                                    .padding(.top, 25)
                                Spacer()
                            }
                            
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(latestBooks, id: \.id) { book in
                                        NavigationLink(destination: SingleBookView(book: book)){
                                            ItemView(item: book, isWhiteText: true)
                                        }
                                    }
                                }
                                .padding(.leading, 15)
                            }
                            .onAppear {
                                fetchDataFromAPI()
                            }
                            
                            
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer()
                    }
                    .background(bottomColor)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(showTabBar ? .visible: .hidden, for: .tabBar)
        .onAppear(){
            showTabBar = false
        }
        .onDisappear(){
            showTabBar = true
        }
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
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let decodedData = try decoder.decode([String: [Book]].self, from: data)
                    if let booksArray = decodedData["data"] {
                        DispatchQueue.main.async {
                            self.latestBooks = booksArray
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
                                
            
//            if let responseData = data {
//                let responseString = String(data: responseData, encoding: .utf8)
//                print("Raw Response Data: \(responseString ?? "N/A")")
//            }
            
//            String AWSPATH = "https://avntestbucket01.s3.ap-northeast-1.amazonaws.com/public/";
//            String AWSBOOKPATH = AWSPATH + "document/";
//            646a88137a2e8
//            String url = WebUrl.AWSBOOKPATH + uid + "/book_data.json";
//            https://avntestbucket01.s3.ap-northeast-1.amazonaws.com/public/document/646a88137a2e8/book_data.json
//            WebUrl.AWSBOOKPATH + uid + "/"
            
            // URL of the JSON data
            let jsonURLString = "https://avntestbucket01.s3.ap-northeast-1.amazonaws.com/public/document/" + book.uid + "/book_data.json"

            if let url = URL(string: jsonURLString) {
                fetchStoryPageData(from: url) { result in
                    switch result {
                    case .success(let bookData):
                        storyPageData = bookData
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
