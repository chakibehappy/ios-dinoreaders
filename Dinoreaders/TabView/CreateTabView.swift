//
//  HomeTabView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 18/09/23.
//

import SwiftUI
import Foundation

struct OwnStoryResponseData: Codable {
    let success: Bool
    let data: [OwnStoryBookData]
}

struct OwnStoryBookData: Codable {
    let audio_url: String
    let cover: String
    let id: Int
    let pages: [OwnStoryPage]
    let template_id: Int
    let title: String
}

struct OwnStoryPage: Codable {
    let id: Int
    let page_audio_url: String
    let page_number: Int
    let page_story: String
}

struct CreateTabView: View {
    
    @EnvironmentObject var settings : UserSettings
    
    @State private var responseData: OwnStoryResponseData?
    @State private var isScrollingEnabled = false
    
    
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
                        
                        HStack{
                            Spacer()
                            NavigationLink(destination:CanvasSelectionView()){
                                Image("btn_create_story")
                                    .resizable()
                                    .frame(width: 200, height: 300)
                                    .scaledToFill()
                                    .clipped()
                                    .padding(.top, 10)
                                    .padding(.bottom, 20)
                            }
                            Spacer()
                        }
                        
                        Text("Your Created Books")
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
                                    ForEach(responseData.data, id: \.id){book in
                                        //NavigationLink(destination: SingleBookView(book: book)){
                                            OwnStoryItemView(item: book)
                                        //}
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
                }
            }
        }
    }
    
    func fetchDataFromAPI() {
        guard let url = URL(string: API.OWN_STORY_API + String(UserDefaultManager.UserID)) else {
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
                    let decodedData = try JSONDecoder().decode(OwnStoryResponseData.self, from: data)
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



struct CreateTabView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTabView()
    }
}

struct OwnStoryItemView: View {
    var item: OwnStoryBookData
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage( url: URL(string: item.cover)) { phase in
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
                        BookImageView(path : item.cover)
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
                .foregroundColor(textColor)
                .font(.custom("Ruddy-Bold", size: 14))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .frame(width: 130, height: 255)
    }
}

