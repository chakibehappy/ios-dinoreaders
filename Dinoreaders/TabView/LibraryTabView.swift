//
//  SearchTabView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 18/09/23.
//

import SwiftUI
import Combine

struct LibraryTabView: View {
    
    @EnvironmentObject var settings : UserSettings
    @State private var isBookTab = true
    @State private var query = ""
    @State private var libraryResponse: LibraryResponseData?
    @State private var books: [SearchResultBook] = []
    @State private var collections: [Collection] = []
    @State private var showBookCollections = false

    @State var selectedCollection : Collection? = nil
    
    let booksHeaderCol : Color = Color(red: 253/255, green: 231/255, blue: 181/255)
    let booksResultCol : Color = Color(red: 105/255, green: 147/255, blue: 221/255)
    let bookBodyCol : Color = Color(red: 255/255, green: 243/255, blue: 219/255)
    let collectionHeaderCol : Color = Color(red: 88/255, green: 206/255, blue: 254/255)
    let collectionResultCol : Color = Color(red: 224/255, green: 190/255, blue: 118/255)
    let collectionBodyCol : Color = Color(red: 171/255, green: 231/255, blue: 255/255)
    let modalTitleCol : Color = Color(red: 0/255, green: 173/255, blue: 239/255)
    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView(.vertical, showsIndicators: false) {
                    VStack( alignment:.leading, spacing : 0){
                        HStack{
                            Image("new_logo")
                                .resizable()
                                .frame(width: 195, height: 52)
                                .scaledToFill()
                                .clipped()
                                .padding(.top, 2.6)
                                .padding(.all, 6.5)
                            
                            Spacer()
                            
                            NavigationLink(destination: ProfileView()){
                                ZStack{
                                    HStack{
                                        VStack(alignment: .leading){
                                            StrokeText(text: "Children 1", width: 1.25, color: .black)
                                                .foregroundColor(.white)
                                                .font(.custom("Ruddy-Black", size: 13))
                                            
                                            HStack(){
                                                StrokeText(text: "Points:", width: 1.25, color: .black)
                                                    .foregroundColor(.white)
                                                    .font(.custom("Ruddy-Black", size: 13))
                                                StrokeText(text: String(settings.TotalPoints), width: 1.25, color: .black)
                                                    .foregroundColor(.white)
                                                    .font(.custom("Ruddy-Black", size: 13))
                                                    .padding(.leading, 5)
                                            }
                                        }
                                        
                                        ZStack(){
                                            AsyncImage(url: URL(string: UserDefaultManager.UserProfilePic)) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                case .failure(_):
                                                    Image(systemName: "person.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 45, height: 45)
                                                        .clipShape(Circle())
                                                        .background(.white)
                                                @unknown default:
                                                    Text("Unknown state")
                                                }
                                            }
                                            .frame(width: 45, height: 45)
                                            .clipShape(Circle())
                                            VStack(){
                                                Spacer()
                                                StrokeText(text: "Lv" + String(settings.ReadingLevel), width: 1.25, color: .black)
                                                    .foregroundColor(.white)
                                                    .font(.custom("Ruddy-Black", size: 13))
                                            }
                                        }
                                    }
                                    .padding(.leading, 10)
                                    .padding(.vertical, 5)
                                    .padding(.trailing, 5)
                                }
                                .background(.yellow)
                                .cornerRadius(23)
                                .padding(.all,10)
                                .frame(height:55)
                            }
                        }
                        
                        ZStack(alignment: .top){
                            VStack{
                                VStack(alignment: .leading, spacing: 0){
                                    Spacer()
                                }
                                .padding(.top, 35)
                                .frame(maxWidth: .infinity, maxHeight:.infinity)
                                .background(isBookTab ? bookBodyCol : collectionBodyCol)
                                
                            }
                            .padding(.top, 25)
                            
                            HStack(spacing:0){
                                Button(action:{}){
                                    StrokeText(text: "Books", width: 1.25, color: .black)
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Black", size: 24))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.black, lineWidth: isBookTab ? 2 : 0)
                                            )
                                }
                                
                                Button(action:{}){
                                    StrokeText(text: "Collections", width: 1.25, color: .black)
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Black", size: 24))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.black, lineWidth: isBookTab ? 0 : 2 )
                                            )
                                }
                            }
                            
                            HStack(spacing:0){
                                Button(action:{
                                    isBookTab = true
                                }){
                                    StrokeText(text: "Books", width: 1.25, color: .black)
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Black", size: 24))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.black, lineWidth: isBookTab ? 0 : 3)
                                            )
                                }
                                .background(booksHeaderCol)
                                .cornerRadius(5)
                                
                                Button(action:{
                                    isBookTab = false
                                }){
                                    StrokeText(text: "Collections", width: 1.25, color: .black)
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Black", size: 24))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.black, lineWidth: isBookTab ? 3 : 0)
                                            )
                                }
                                .background(collectionHeaderCol)
                                .cornerRadius(5)
                            }
                            .padding(.top, 1.5)
                        }
                        .padding(.top, 25)
                        
                        if(isBookTab)
                        {
                            VStack(spacing : 0){
                                HStack()
                                {
                                    Text("Favourites")
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Black", size: 20))
                                        .padding(.horizontal, 13)
                                        .background(.pink)
                                        .cornerRadius(6.5)
                                        .underline(true, color: .white)
                                        .padding(.leading, 15)
                                        .padding(.bottom, 2)
                                        .padding(.top, 5)
                                    Spacer()
                                }
                                .background(bookBodyCol)
                                .padding(.bottom, 15)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(alignment: .top, spacing:15){
                                        VStack{}
                                        if let lib = libraryResponse {
                                            if let content = lib.data[0].content {
                                                ForEach(content, id: \.id) { book in
                                                    NavigationLink(destination: SingleBookView(book_id: book.id)){
                                                        LibraryItemView(item: book, isWhiteText: false, toogleFunction: fetchBookDataFromAPI)
                                                    }
                                                }
                                            }
                                        }
                                        VStack{}
                                    }
                                }
                                .background(bookBodyCol)
                                
                                VStack(){
                                    Spacer()
                                }
                                .frame(width:UIScreen.main.bounds.width, height: max(0, UIScreen.main.bounds.height - (CGFloat(255 + 300))))
                                .background(bookBodyCol)
                            }
                            .background(bookBodyCol)
                        }
                        else
                        {
                            VStack(spacing : 0){
                                HStack()
                                {
                                    Text("All Collections")
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Black", size: 20))
                                        .padding(.horizontal, 13)
                                        .background(.blue)
                                        .cornerRadius(6.5)
                                        .underline(true, color: .white)
                                        .padding(.leading, 10)
                                        .padding(.bottom, 2)
                                        .padding(.top, 5)
                                    Spacer()
                                }
                                .background(collectionBodyCol)
                                .padding(.bottom, 15)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(alignment: .top, spacing:20){
                                        ForEach(collections, id: \.id){ collection in
                                            Button(action:{
                                                selectedCollection = collection
                                                showBookCollections = true
                                            }){
                                                CollectionSearchView(item: collection, isWhiteText: false, width:130, height:195)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                                .background(collectionBodyCol)
                                
                                VStack(){
                                    Spacer()
                                }
                                .frame(width:UIScreen.main.bounds.width, height: max(0, UIScreen.main.bounds.height - (CGFloat(255 + 300))))
                                .background(collectionBodyCol)
                            }
                            .background(collectionBodyCol)
                        }
                    }
                }
                .background(
                    Image("home_gradient_bg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                )
                .onAppear(){
                    fetchBookDataFromAPI()
                    fetchCollectionDataFromAPI()
                }
            }
            .sheet(item: $selectedCollection){ col in
                if(collections.count > 0)
                {
                    NavigationStack(){
                        HStack(){
                            Text(col.name)
                                .foregroundColor(.white)
                                .font(.custom("Ruddy-Black", size: 20))
                                .padding(.horizontal, 13)
                                .background(modalTitleCol)
                                .cornerRadius(6.5)
                                .underline(true, color: .white)
                                .padding(.leading, 13)
                                .padding(.bottom, 2)
                                .padding(.top, 15)
                            Spacer()
                            
                            Button(action:{
                                showBookCollections = false
                                selectedCollection = nil
                            })
                            {
                                Image("close_icon")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .scaledToFill()
                                    .clipped()
                                    .padding(.horizontal, 10)
                                    .padding(.top, 10)
                            }
                        }
                        
                        ScrollView(.vertical){
                            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 0) {
                                ForEach(col.books, id: \.id){book in
                                    NavigationLink(destination: SingleBookView(book_id: book.id)){
                                        ItemBookCollectionView(item: book, isWhiteText: false)
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        
                        
                        Button(action:{
                            
                        }){
                            Text("Add to Library")
                                .padding()
                        }
                    }
                }
            }
        }
    }
        
    
    public func fetchBookDataFromAPI() {
        guard let url = URL(string: API.GETFAVOURITEBOOK_API) else {
            return
        }
            
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
                
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(LibraryResponseData.self, from: data)
                    DispatchQueue.main.async {
                        self.libraryResponse = result
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
    
    
    func fetchCollectionDataFromAPI() {
        guard let url = URL(string: API.GETALLCOLLECTIONS_API) else {
            return
        }
            
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
                
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(CollectionResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.collections = result.data
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }

            }

//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//
//            guard let data = data else {
//                print("No data received")
//                return
//            }
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("Raw JSON Response: \(jsonString)")
//            } else {
//                print("Unable to convert data to string")
//            }
        }.resume()
        
    }
}

struct LibraryTabView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryTabView()
    }
}

struct LibraryItemView: View {
    @State var item: LibraryContentItem
    var isWhiteText: Bool = false
    var toogleFunction: () -> Void
    
    @State var cancellable: AnyCancellable?
    
    var body: some View {
        ZStack(){
            VStack(alignment: .leading) {
                if let img = item.image_url{
                    
                    AsyncImage( url: URL(string: img)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .cornerRadius(5)
                                .frame(width: 130, height: 195)
                        case .failure(let error):
                            if error.localizedDescription == "cancelled"{
                                BookImageView(path : img)
                            }
                            else{
                                Text("Error: \(error.localizedDescription)")
                            }
                        @unknown default:
                            Text("Unknown state")
                        }
                    }
                    .frame(width: 130, height: 195)
                    .clipped()
                    .cornerRadius(5)
                }
                
                let textColor : Color = Color(red: 57/255, green: 111/255, blue: 162/255)
                if let title = item.title{
                    Text(title)
                        .foregroundColor(isWhiteText ? .white : textColor)
                        .font(.custom("Ruddy-Bold", size: 14))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
            .frame(width: 130, height: 255)
            
            VStack(){
                HStack(alignment: .top){
                    Spacer()
                    Button(action:{
                        ToogleFavourite(bookId: String(item.id))
                    }){
                        Image("heart")
                            .resizable()
                            .frame(width: 24, height: 22)
                            .scaledToFill()
                            .clipped()
                            .padding(.vertical, 8)
                            .padding(.horizontal, 8)
                    }
                }
                Spacer()
            }
            .frame(width: 130, height: 255)
        }
        .frame(width: 130, height: 255)
    }
    
    func ToogleFavourite(bookId : String)
    {
        let url = URL(string: API.TOOGLEFAVOURITE_API)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = "book_id=\(bookId)".data(using: .utf8) // Create form data body
        
        request.httpBody = body
        
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
                    .map(\.data)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break // Do nothing for now
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }, receiveValue: { data in
                        // Print the raw response data
                        if let string = String(data: data, encoding: .utf8) {
                            // Print("Raw Response: \(string)")
                            // run the function here
                            toogleFunction()
                        }
                    })
    }
}
