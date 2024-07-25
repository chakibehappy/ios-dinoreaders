//
//  ContentView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 18/09/23.
//

import SwiftUI

struct ContentView: View {
    struct LoginRequest: Codable {
        let email: String
        let password: String
    }

    @State private var email = UserDefaultManager.UserEmail
    @State private var password = UserDefaultManager.UserPassword
    @State private var isWrongEmail = 0
    @State private var isWrongPassword = 0
    
    @EnvironmentObject var settings : UserSettings
    @EnvironmentObject var readingTimeManager : ReadingTimeManager
    
    @State private var dinoEggs : [DinoEgg] = []
    
    init(){
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
//        for familyName in UIFont.familyNames{
//            print(familyName)
//        }
    }

    var body: some View {
        if settings.isLoggedIn
        {
            if !settings.showDinoEggWindow{
                HomeView()
            }
            else{
                DinoEggsInfoView(dinoEggs: dinoEggs)
            }
        }
        else
        {
            NavigationStack() {
                ZStack {
                    Image(!UserDefaults.standard.bool(forKey: "login") ? "login_bg" : "home_gradient_bg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                    VStack{
                        if !UserDefaults.standard.bool(forKey: "login")
                        {
                            Image("logo")
                                .resizable()
                                .frame(width: 239, height: 84)
                                .scaledToFill()
                                .clipped()
                                .padding(.top, 65)
                                .padding(.bottom, 65)
                            
                            TextField("EMAIL", text: $email)
                                .padding()
                                .padding(.horizontal, 14)
                                .frame(width:UIScreen.main.bounds.width - 52, height: 65)
                                .foregroundColor(.black)
                                .background(.white)
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(.black, lineWidth:4)
                                )
                                .font(.custom("Quicksand-Bold", size: 21))
                            
                            SecureField("PASSWORD", text: $password)
                                .padding()
                                .padding(.horizontal, 14)
                                .frame(width:UIScreen.main.bounds.width - 52, height: 65)
                                .foregroundColor(.black)
                                .background(.white)
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(.black, lineWidth:4)
                                )
                                .font(.custom("Quicksand-Bold", size: 21))
                            
                            Button("LOGIN") { login(email: email, password: password)}
                                .foregroundColor(.white)
                                .frame(width:UIScreen.main.bounds.width - 52, height: 65)
                                .background(.black)
                                .cornerRadius(20)
                                .padding(.top, 26)
                                .font(.custom("Quicksand-Bold", size: 21))
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .onAppear(){
                        if UserDefaults.standard.bool(forKey: "login"){
                            //testCheckDinoEggData()
                            checkDinoEggData()
                        }
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }

    func login(email: String, password: String) {
        // Create the request URL
        let urlString = "http://dinoreaders.com/api/login"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        // Create the login request data
        let loginData = LoginRequest(email: email, password: password)

        // Serialize the request data to JSON
        let encoder = JSONEncoder()
        guard let requestData = try? encoder.encode(loginData) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create a URLSession task to send the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("HTTP Error: Invalid response")
                return
            }
            
            if let responseData = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                        // Now you have the JSON data as a dictionary
                        print(json)
                        if let success = json["success"] as? Bool,
                           let dataDict = json["data"] as? [String: Any],
                           let accessToken = dataDict["access_token"] as? String,
                           let expiresAt = dataDict["expires_at"] as? String,
                           let profileId = dataDict["profile_id"] as? Int,
                           let profileImage = dataDict["profile_image"] as? String,
                           let settingPassword = dataDict["setting_password"] as? String,
                           let tokenType = dataDict["token_type"] as? String,
                           let userId = dataDict["user_id"] as? Int
                        {
//                                    print("Success: \(success)")
//                                    print("Access Token: \(accessToken)")
//                                    print("Expires At: \(expiresAt)")
//                                    print("Profile ID: \(profileId)")
//                                    print("Profile Image: \(profileImage)")
//                                    print("Setting Password: \(settingPassword)")
//                                    print("Token Type: \(tokenType)")
//                                    print("User ID: \(userId)")
                            
                            if(success){
                                UserDefaultManager.UserEmail = email
                                UserDefaultManager.UserPassword = password
                                UserDefaultManager.UserProfilePic = profileImage
                                UserDefaultManager.UserAccessToken = accessToken
                                UserDefaultManager.ProfileID = profileId
                                UserDefaultManager.UserID = userId
                                
                                // get active profile name
                                guard let url = URL(string: API.PROFILESETTING_API + String(UserDefaultManager.UserID)) else {
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
                                            let result = try decoder.decode(ReadingProfileData.self, from: data)
                                            
                                            if result.success == true {
                                                for profile in result.data {
                                                    if profile.profile_id == UserDefaultManager.ProfileID{
                                                        UserDefaultManager.ProfileName = profile.profile[0].name
                                                        settings.ReadingSetting = profile
                                                        if profile.calculated_by == "Each Login For" {
                                                            readingTimeManager.resetTracking()
                                                        }
                                                        break
                                                    }
                                                }
                                                checkAndRegisterDinoEggSetting();
                                            }
                                        } catch {
                                            print("Error decoding reading profiles data JSON: \(error)")
                                        }
                                    }
                                }.resume()
                            }
                            
                        } else {
                            print("Error parsing JSON")
                        }
                    }
                } catch {
                    print("Error parsing response data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func checkAndRegisterDinoEggSetting(){
        guard let url = URL(string: API.GETDINO_EGG_COUNTER_API) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    //print("Response Check & Register Dino SEgg Setting: \(jsonString)")
                    //testCheckDinoEggData()
                    checkDinoEggData()
                }
            }
        }.resume()
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
                        print(dinoEggs)
                        getDinoEgg = true
                    }
                }
                DispatchQueue.main.async {
                    settings.showDinoEggWindow = getDinoEgg
                    settings.isLoggedIn = true
                }
            } catch {
                print("Error decoding JSON: \(error)")
                DispatchQueue.main.async {
                    settings.isLoggedIn = true
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
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response Check Dino Egg: \(jsonString)")
                }
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
                            print(dinoEggs)
                            getDinoEgg = true
                        }
                    }
                    DispatchQueue.main.async {
                        settings.showDinoEggWindow = getDinoEgg
                        settings.isLoggedIn = true
                    }
                } catch {
                    print("Error decoding Dino Eggs Obtain data JSON: \(error)")
                    DispatchQueue.main.async {
                        settings.isLoggedIn = true
                    }
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
