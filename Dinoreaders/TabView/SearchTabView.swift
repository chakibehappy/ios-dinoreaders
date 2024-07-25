//
//  SearchTabView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 18/09/23.
//

import SwiftUI

struct SearchResponseData: Codable {
    let success: Bool
    let data: [SearchResultBook]
}

struct SearchResultBook: Identifiable, Codable {
    let id: Int
    let reading_level: String
    let title: String
    let description: String
    let author: String
    let image_url: String
    let lang: String
}

struct SearchTabView: View {
    
    @EnvironmentObject var settings : UserSettings
    @State private var isBookTab = true
    @State private var query = ""
    @State private var books: [SearchResultBook] = []
    @State private var collections: [Collection] = []
    @State private var showBookCollections = false
    //@State private var selectedCollection = 0
    @State var selectedCollection : Collection? = nil
    
    let booksHeaderCol : Color = Color(red: 253/255, green: 231/255, blue: 181/255)
    let booksResultCol : Color = Color(red: 105/255, green: 147/255, blue: 221/255)
    let bookBodyCol : Color = Color(red: 255/255, green: 243/255, blue: 219/255)
    let collectionHeaderCol : Color = Color(red: 88/255, green: 206/255, blue: 254/255)
    let collectionResultCol : Color = Color(red: 224/255, green: 190/255, blue: 118/255)
    let collectionBodyCol : Color = Color(red: 171/255, green: 231/255, blue: 255/255)
    let modalTitleCol : Color = Color(red: 0/255, green: 173/255, blue: 239/255)
    
    
    var filteredItems: [SearchResultBook] {
        if(query == ""){
            return books
        }
        return books.filter { book in
            return book.title.lowercased().contains(query.lowercased())
        }
    }
    
    var filteredCollections: [Collection] {
        if(query == ""){
            return collections
        }
        return collections.filter { collection in
            return collection.name.lowercased().contains(query.lowercased())
        }
    }
    
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
                                            StrokeText(text: UserDefaultManager.ProfileName, width: 1.25, color: .black)
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
                                    
                                    VStack{
                                        
                                        TextField("Search", text: $query)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 24)
                                            .foregroundColor(.black)
                                            .background(.white)
                                            .cornerRadius(30)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 30)
                                                    .stroke(.black, lineWidth:0)
                                            )
                                            .font(.custom("Ruddy-Black", size:24))
                                    }
                                    .padding(.horizontal,12)
                                    .padding(.top, 10)
                                    .padding(.bottom, 5)
                                    
                                    
                                    Text("Results")
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Black", size: 20))
                                        .padding(.horizontal, 13)
                                        .background(isBookTab ? booksResultCol : collectionResultCol)
                                        .cornerRadius(6.5)
                                        .underline(true, color: .white)
                                        .padding(.leading, 13)
                                        .padding(.bottom, 2)
                                        .padding(.top, 15)
                                    
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
                            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 0) {
                                ForEach(filteredItems, id: \.id){book in
                                    NavigationLink(destination: SingleBookView(book_id: book.id)){
                                        ItemSearchView(item: book, isWhiteText: false)
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            .background(bookBodyCol)
                        }
                        else
                        {
                            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 0) {
                                ForEach(filteredCollections, id: \.id){ collection in
                                    Button(action:{
                                        selectedCollection = collection
                                        showBookCollections = true
                                    }){
                                        CollectionSearchView(item: collection, isWhiteText: false)
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            .background(collectionBodyCol)
                        }
                    }
                }
                .background(
                    ZStack{
                        Image("home_gradient_bg")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        if isBookTab {
                            bookBodyCol
                                .edgesIgnoringSafeArea(.all)
                                .frame(maxHeight: .infinity, alignment: .top)
                                .padding(.top, 250)
                        } else {
                            collectionBodyCol
                                .edgesIgnoringSafeArea(.all)
                                .frame(maxHeight: .infinity, alignment: .top)
                                .padding(.top, 250)
                        }
                    }
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
        
    
    func fetchBookDataFromAPI() {
        guard let url = URL(string: API.GETALLBOOK_API) else {
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
                    let result = try decoder.decode(SearchResponseData.self, from: data)
                    DispatchQueue.main.async {
                        self.books = result.data
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
                    print("Error decoding JSON collection : \(error)")
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

struct SearchTabView_Previews: PreviewProvider {
    static var previews: some View {
        SearchTabView()
    }
}


struct ItemSearchView: View {
    var item: SearchResultBook
    var isWhiteText: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage( url: URL(string: item.image_url)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .cornerRadius(5)
                        .frame(width: 115, height: 180)
                case .failure(let error):
                    if error.localizedDescription == "cancelled"{
                        BookImageView(path : item.image_url)
                    }
                    else{
                        Text("Error: \(error.localizedDescription)")
                    }
                @unknown default:
                    Text("Unknown state")
                }
            }
            .frame(width: 115, height: 180)
            .clipped()
            .cornerRadius(5)
            
            let textColor : Color = Color(red: 57/255, green: 111/255, blue: 162/255)
            Text(item.title)
                .foregroundColor(isWhiteText ? .white : textColor)
                .font(.custom("Ruddy-Bold", size: 14))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .frame(width: 115, height: 240)
    }
}


struct CollectionSearchView: View {
    var item: Collection
    var isWhiteText: Bool = false
    var width = 115
    var height = 180
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading){
                if(item.books.count > 2){
                    AsyncImage( url: URL(string: item.books[2].image_url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .frame(width: 80, height: 100)
                        case .failure(let error):
                            if error.localizedDescription == "cancelled"{
                                BookImageView(path : item.books[2].image_url)
                            }
                            else{
                                Text("Error: \(error.localizedDescription)")
                            }
                        @unknown default:
                            Text("Unknown state")
                        }
                    }
                    .scaledToFill()
                    .frame(width: 80, height: 100)
                    .clipped()
                    .padding(.bottom, -80)
                    .padding(.leading, -35)
                }
                
                
                if(item.books.count > 3){
                    AsyncImage( url: URL(string: item.books[3].image_url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .frame(width: 80, height: 100)
                        case .failure(let error):
                            if error.localizedDescription == "cancelled"{
                                BookImageView(path : item.books[3].image_url)
                            }
                            else{
                                Text("Error: \(error.localizedDescription)")
                            }
                        @unknown default:
                            Text("Unknown state")
                        }
                    }
                    .scaledToFill()
                    .frame(width: 80, height: 100)
                    .clipped()
                    .padding(.top, -80)
                    .padding(.trailing, -35)
                }
            
                if(item.books.count > 0){
                    AsyncImage( url: URL(string: item.books[0].image_url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .frame(width: 80, height: 100)
                        case .failure(let error):
                            if error.localizedDescription == "cancelled"{
                                BookImageView(path : item.books[0].image_url)
                            }
                            else{
                                Text("Error: \(error.localizedDescription)")
                            }
                        @unknown default:
                            Text("Unknown state")
                        }
                    }
                    .scaledToFill()
                    .frame(width: 80, height: 100)
                    .clipped()
                    .padding(.top, -80)
                    .padding(.leading, -35)
                }
                
                
                if(item.books.count > 1){
                    AsyncImage( url: URL(string: item.books[1].image_url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .frame(width: 80, height: 100)
                        case .failure(let error):
                            if error.localizedDescription == "cancelled"{
                                BookImageView(path : item.books[1].image_url)
                            }
                            else{
                                Text("Error: \(error.localizedDescription)")
                            }
                        @unknown default:
                            Text("Unknown state")
                        }
                    }
                    .scaledToFill()
                    .frame(width: 80, height: 100)
                    .clipped()
                    .padding(.bottom, -80)
                    .padding(.trailing, -35)
                }
            }
            .frame(width: CGFloat(width), height: CGFloat(height))
            .background(.white)
            .cornerRadius(5)
            
            let textColor : Color = Color(red: 57/255, green: 111/255, blue: 162/255)
            Text(item.name)
                .foregroundColor(isWhiteText ? .white : textColor)
                .font(.custom("Ruddy-Bold", size: 14))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .frame(width: CGFloat(width) , height: CGFloat(height + 60))
    }
}

struct ItemBookCollectionView: View {
    var item: CollectionBook
    var isWhiteText: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage( url: URL(string: item.image_url)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .cornerRadius(5)
                        .frame(width: 115, height: 180)
                case .failure(let error):
                    if error.localizedDescription == "cancelled"{
                        BookImageView(path : item.image_url)
                    }
                    else{
                        Text("Error: \(error.localizedDescription)")
                    }
                @unknown default:
                    Text("Unknown state")
                }
            }
            .frame(width: 115, height: 180)
            .clipped()
            .cornerRadius(5)
            
            let textColor : Color = Color(red: 57/255, green: 111/255, blue: 162/255)
            Text(item.title)
                .foregroundColor(isWhiteText ? .white : textColor)
                .font(.custom("Ruddy-Bold", size: 14))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .frame(width: 115, height: 240)
    }
}
