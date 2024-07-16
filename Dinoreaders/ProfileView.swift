//
//  ProfileView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 25/09/23.
//

import SwiftUI

struct ProfileResponseData: Codable {
    let success: Bool
    let data: [ProfileData]
}

struct ProfileData: Codable {
    let dob: String?
    let dra: Int
    let grl: String
    let id: Int
    let img_url: String
    let max_created_story: Int
    let name: String
    let reading_level: Int
    let pivot: PivotData
}

struct PivotData: Codable {
    let profile_id: Int
    let user_id: Int
}

struct ProfileView: View {
    
    @State private var responseData: ProfileResponseData?
    @State private var isOpenSetting: Bool = false
    
    @EnvironmentObject var settings : UserSettings
    @State var showTabBar : Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    let bgColor : Color = Color(red: 103/255, green: 224/255, blue: 147/255)
    let profileBoxColor : Color = Color(red: 180/255, green: 240/255, blue: 202/225)
    
    let yellow : Color = Color(red:254/255, green: 242/255, blue:0)
    let yellowGradients: [Color] = [
        Color(red:1, green: 168/255, blue:1/255),
        Color(red:1, green: 213/255, blue:1/255),
        Color.white
    ]
    
    let blue : Color = Color(red:82/255, green: 120/255, blue:1)
    let blueGradients: [Color] = [
        Color(red:79/255, green: 75/255, blue:1),
        Color(red:85/255, green: 99/255, blue:1),
        Color.white
    ]
    
    let orange : Color = Color(red:1, green: 131/255, blue:51/255)
    let orangeGradients: [Color] = [
        Color(red:234/255, green: 107/255, blue:38/255),
        Color(red:1, green: 131/255, blue:51/255),
        Color.white
    ]
    
    var body: some View {
        NavigationStack(){
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
                    
                    HStack{
                        Spacer()
                        VStack{
                            Spacer()
                            StrokeText(text: "Profile", width: 1.25, color: .black)
                                .foregroundColor(.white)
                                .font(.custom("Ruddy-Black", size: 34))
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .frame(height: 85)
                .background(bgColor)
                
                ScrollView(.vertical){
                    GeometryReader { geometry in
                        HStack{
                            HStack{
                                ZStack{
                                    AsyncImage(url: URL(string: UserDefaultManager.UserProfilePic)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        case .failure(let error):
                                            Text(error.localizedDescription)
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 110, height: 110)
                                                .clipShape(Circle())
                                                .background(.white)
                                        @unknown default:
                                            Text("Unknown state")
                                        }
                                    }
                                    .frame(width: 110, height: 110)
                                    .clipShape(Circle())
                                    VStack{
                                        Spacer()
                                        StrokeText(text: "Lv" + String(settings.ReadingLevel), width: 1.25, color: .black)
                                            .foregroundColor(.white)
                                            .font(.custom("Ruddy-Black", size: 20))
                                    }
                                }
                                .frame(width: 150)
                                
                                VStack{
                                    Image("new_logo")
                                        .resizable()
                                        .frame(width: 190, height: 50)
                                        .scaledToFill()
                                        .clipped()
                                    HStack{
                                        StrokeText(text: "Children1", width: 1.25, color: .black)
                                            .foregroundColor(.white)
                                            .font(.custom("Ruddy-Black", size: 24))
                                        Spacer()
                                    }
                                    HStack{
                                        StrokeText(text: "Books Read:", width: 1.25, color: .black)
                                            .foregroundColor(.white)
                                            .font(.custom("Ruddy-Black", size: 16))
                                        Spacer()
                                        StrokeText(text: String(settings.TotalBooksRead), width: 1.25, color: .black)
                                            .foregroundColor(.white)
                                            .font(.custom("Ruddy-Black", size: 16))
                                            .padding(.trailing, 10)
                                    }
                                    HStack{
                                        StrokeText(text: "Points:", width: 1.25, color: .black)
                                            .foregroundColor(.white)
                                            .font(.custom("Ruddy-Black", size: 16))
                                        Spacer()
                                        StrokeText(text: String(settings.TotalPoints), width: 1.25, color: .black)
                                            .foregroundColor(.white)
                                            .font(.custom("Ruddy-Black", size: 16))
                                            .padding(.trailing, 10)
                                    }
                                }
                                
                            }
                            .padding(.all, 10)
                            .background(profileBoxColor)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 10)
                        .frame(width: geometry.size.width, height: 165)
                
                    }
                    .frame(height: 185)
                    
                    
                    NavigationLink(destination: EditDinoBuddyView())
                    {
                        GradientViewButton(width:250, text: "Dino Eggs", btnCol: yellow, colors: yellowGradients, textSize: 18)
                    }
                    
                    NavigationLink(destination: EditDinoBuddyView())
                    {
                        GradientViewButton(width:250, text: "Edit your Dino Buddy", btnCol: yellow, colors: yellowGradients, textSize: 18)
                    }
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 2)
                        .padding(.horizontal, 10)
                    
                    HStack{
                        StrokeText(text: "User Profiles", width: 1.25, color: .black)
                            .foregroundColor(.white)
                            .font(.custom("Ruddy-Black", size: 24))
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    HStack{
                        StrokeText(text: "Tap to switch", width: 1.25, color: .black)
                            .foregroundColor(.white)
                            .font(.custom("Ruddy-Black", size: 12))
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            
                            if let responseData = responseData {
                                ForEach(responseData.data, id: \.id){profile in
                                    ProfileImageButton(image: profile.img_url, action: {
                                        // Handle button action here
                                    })
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding()
                    }
                    
                    NavigationLink(destination: CreateNewProfileView())
                    {
                        GradientViewButton(width:250, text: "Create new Profile", btnCol: blue, colors: blueGradients, textSize: 18)
                    }
                    
                    NavigationLink(destination: ApplicationSettingView())
                    {
                        GradientViewButton(width:250, text: "Setting", btnCol: blue, colors: blueGradients, textSize: 18)
                    }
                    
                    GradientButton(width:250, text: "Logout", btnCol: orange, colors: orangeGradients, textSize: 18) {
                        logout()
                    }
                }
            }
            .background(bgColor)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(showTabBar ? .visible: .hidden, for: .tabBar)
        .onAppear(){
            showTabBar = false
            getUserInfo()
            getProfileList()
        }
        .onDisappear(){
            showTabBar = true
        }
    }
    
    func logout(){
        settings.isLoggedIn = false
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func getProfileList(){
        guard let url = URL(string: API.PROFILE_API) else {
            return
        }
            
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
                
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(ProfileResponseData.self, from: data)
                    DispatchQueue.main.async {
                    self.responseData = decodedData
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
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
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

struct GradientButton: View {
    var width: CGFloat
    var text: String
    var btnCol: Color
    var colors: [Color]
    var textSize: CGFloat
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack{
                StrokeText(text: text, width: 1.25, color: .black)
                    .foregroundColor(.white)
                    .font(.custom("Ruddy-Black", size: textSize))
                    .padding(.vertical, 10)
                    .frame(width: width)
            }
            .background(btnCol)
            .cornerRadius(10)
            .padding(.all,5)
                
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black, lineWidth: 1.5)
        )
        .padding(.vertical, 5)
    }
}

struct GradientViewButton: View {
    var width: CGFloat
    var text: String
    var btnCol: Color
    var colors: [Color]
    var textSize: CGFloat

    var body: some View {
        ZStack {
            ZStack{
                StrokeText(text: text, width: 1.25, color: .black)
                    .foregroundColor(.white)
                    .font(.custom("Ruddy-Black", size: textSize))
                    .padding(.vertical, 10)
                    .frame(width: width)
            }
            .background(btnCol)
            .cornerRadius(10)
            .padding(.all,5)
                
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black, lineWidth: 1.5)
        )
        .padding(.vertical, 5)
    }
}


struct ProfileImageButton: View {
    var image : String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            AsyncImage(url: URL(string: image)) { phase in
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
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .background(.white)
                @unknown default:
                    Text("Unknown state")
                }
            }
            .frame(width: 80, height: 80)
            .background(.white)
            .clipShape(Circle())
                
        }
    }
}
