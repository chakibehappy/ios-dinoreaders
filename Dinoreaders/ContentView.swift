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
            
        //    init(){
        //        for familyName in UIFont.familyNames{
        //            print(familyName)
        //        }
        //    }
            
            init(){
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }

            var body: some View {
                if settings.isLoggedIn
                {
                    HomeView()
                }
                else
                {
                    if UserDefaults.standard.bool(forKey: "login") == true{
                        HomeView()
                    }
                    else
                    {
                        NavigationStack() {
                            ZStack {
                                Image("login_bg")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .ignoresSafeArea()
                                VStack{
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
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .navigationBarHidden(true)
                        }
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
                    // Check for errors
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }

                    // Check the HTTP response status code
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        print("HTTP Error: Invalid response")	
                        return
                    }
                    
                    if let responseData = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                                // Now you have the JSON data as a dictionary
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
                                    // You can now access individual values from the JSON
                                    print("Success: \(success)")
                                    print("Access Token: \(accessToken)")
                                    print("Expires At: \(expiresAt)")
                                    print("Profile ID: \(profileId)")
                                    print("Profile Image: \(profileImage)")
                                    print("Setting Password: \(settingPassword)")
                                    print("Token Type: \(tokenType)")
                                    print("User ID: \(userId)")
                                    
                                    if(success){
                                        UserDefaultManager.UserEmail = email
                                        UserDefaultManager.UserPassword = password
                                        UserDefaultManager.UserProfilePic = profileImage
                                        UserDefaultManager.UserAccessToken = accessToken
                                        UserDefaultManager.ProfileID = profileId
                                        UserDefaultManager.UserID = userId
                                        DispatchQueue.main.async {
                                            settings.isLoggedIn = true
                                        }
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
        }

        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
            }
        }
