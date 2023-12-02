//
//  HomeTabView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 18/09/23.
//

import SwiftUI
import Foundation

struct ResponseData: Codable {
    let success: Bool
    let data: [Section]
}

struct Section: Codable {
    let name: String
    let type: String
    let title_icon: String
    let content: [Book]
}

struct Book: Identifiable, Codable {
    let id: Int
    let uid: String
    let title: String
    let description: String
    let short_description: String
    let author: String
    let image_url: String
    let pagecount: Int
    let favourite: Bool
    let reading_level: String
    let read_url: String
    let read_to_me: Bool
    let level: [AgeLevel]
    let categories: [Category]
    let lang: String
    let published: Int
    let saved: Int
}

struct AgeLevel: Codable {
    let name: String
    let color: String
}

struct Category: Codable {
    let name: String
    let color: String
}


struct HomeTabView: View {
    
    @State private var responseData: ResponseData?
    @State private var isScrollingEnabled = false
    
    @EnvironmentObject var settings : UserSettings
    
    
    init() {
       UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        NavigationStack{
            ScrollView(.vertical, showsIndicators: false) {
                ZStack{
                    Image("home_gradient_bg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    VStack(alignment: .leading) {
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
                        
                        // List Title Text
                        Text("Recommended For You")
                            .foregroundColor(.white)
                            .font(.custom("Ruddy-Black", size: 20))
                            .padding(.horizontal, 13)
                            .background(.orange)
                            .cornerRadius(6.5)
                            .underline(true, color: .white)
                            .padding(.leading, 13)
                            .padding(.bottom, 2)
                            .padding(.top, 15)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                if let responseData = responseData {
                                    ForEach(responseData.data[1].content, id: \.id) { book in
                                        NavigationLink(destination: SingleBookView(book: book)){
                                            ItemView(item: book, isWhiteText: false)
                                        }
                                    }
                                }
                            }
                            .padding(.leading, 15)
                        }
                        .onAppear {
                            getUserInfo()
                            fetchDataFromAPI()
                        }
                        
                        
                        Text("Top Books")
                            .foregroundColor(.white)
                            .font(.custom("Ruddy-Black", size: 20))
                            .padding(.horizontal, 13)
                            .background(.orange)
                            .cornerRadius(6.5)
                            .underline(true, color: .white)
                            .padding(.leading, 13)
                            .padding(.bottom, 2)
                        
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                if let responseData = responseData {
                                    ForEach(responseData.data[2].content, id: \.id){book in
                                        NavigationLink(destination: SingleBookView(book: book)){
                                            ItemView(item: book, isWhiteText: false)
                                        }
                                    }
                                }
                            }
                            .padding(.leading, 15)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    func getUserInfo(){
        guard let url = URL(string: API.GETPROFILEINFO_API + String(UserDefaultManager.ProfileID)) else {
            return
        }
            
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
                
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                       DispatchQueue.main.async {
                           
                           if let readingLevel = json["readingLevel"] as? Int {
                               settings.ReadingLevel = readingLevel
                           }
                           if let totalPoints = json["totalPoints"] as? String {
                               if let convertedValue = Int(totalPoints) {
                                   settings.TotalPoints = convertedValue
                               }
                           }
                           if let bookCount = json["bookCount"] as? Int {
                               settings.TotalBooksRead = bookCount
                           }
                       }
                   }
               } catch {
                   print("Error decoding JSON: \(error)")
               }
            }
        }.resume()
    }
    
    func fetchDataFromAPI() {
        guard let url = URL(string: API.DASHBOARD_API) else {
            return
        }
            
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
                
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(ResponseData.self, from: data)
                    DispatchQueue.main.async {
                        self.responseData = decodedData
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
}



struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}

struct BookImageView: View{
    var path: String
    
    var body: some View{
        AsyncImage( url: URL(string: path)) { phase in
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
                    BookImageView(path: path)
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
}

struct ItemView: View {
    var item: Book
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
                        .frame(width: 130, height: 195)
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
            .frame(width: 130, height: 195)
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
        .frame(width: 130, height: 255)
    }
}

var items: [Book] = []

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}
