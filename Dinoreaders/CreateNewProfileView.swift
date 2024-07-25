//
//  CreateNewProfileView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 01/11/23.
//
import Foundation
import SwiftUI
import Alamofire


struct CreateNewProfileView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var username = ""
    
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false
    
    @State private var selectedDate = Date()
    @State private var isSelectingDate = false
    @State private var isPickerPresented = false
    
    @State private var isButtonVisible = true
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-yyyy"
        return formatter
    }()
    
    var body: some View {
        NavigationStack(){
            VStack{
                ZStack{
                    HStack{
                        Spacer()
                        VStack{
                            Spacer()
                            Text("Create Profile")
                                .foregroundColor(.white)
                                .font(.custom("Quicksand-Bold", size: 26))
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    HStack{
                        Button( action: { self.presentationMode.wrappedValue.dismiss()})
                        {
                            Image("backarrow")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .scaledToFill()
                                .clipped()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                        }
                        Spacer()
                    }
                }
                .frame(height: 45)
                
                Button(action:{
                    isImagePickerPresented = true
                })
                {
                    HStack(){
                        if let image = selectedImage {
                            Image(uiImage:image)
                                .resizable()
                                .scaledToFit()
                                .background(.white)
                                .frame(width: 130, height: 130)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .background(.white)
                                .frame(width: 130, height: 130)
                                .clipShape(Circle())
                        }
                    }
                    .background(.white)
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                    .padding(.bottom, 15)
                }
                
                TextField("Name", text: $username)
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
                
                TextField(
                    "Date of Birth",
                    text: isSelectingDate ? .constant(dateFormatter.string(from: selectedDate)) : .constant("")
                )
                    .disabled(true)
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
                    .onTapGesture {
                        isPickerPresented = true
                        isSelectingDate = true
                    }
                
                if isButtonVisible{
                    Button("CREATE") {
                        isButtonVisible = false
                        saveProfile()
                    }
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
            .background(Image("login_bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            )
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $isPickerPresented) {
            MonthYearPicker(selectedDate: $selectedDate)
            Button(action: {
                isPickerPresented = false
            }) {
                Text("CONFIRM")
                    .padding()
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }

    func uploadImage(image : UIImage) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.1) else {
            isButtonVisible = true
            return
        }
        
        let imageSizeInKB = Double(imageData.count) / 1024.0
        print(imageSizeInKB)
        if imageSizeInKB > 2048 {
            // Display an error message to the user or prevent the upload
            print("Image size exceeds the limit")
            isButtonVisible = true
            return
        }
        
        guard let url = URL(string: API.SAVE_PROFILE_API) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set Bearer token
        let authHeader = "Bearer \(UserDefaultManager.UserAccessToken)"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"img_url\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(username)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"dob\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(dateFormatter.string(from: selectedDate))\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        request.timeoutInterval = 600
        request.networkServiceType = .responsiveData
        //request.networkServiceType = .responsiveAV
        
        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print(error)
//            }
//            print(response)
            DispatchQueue.main.async {
                isButtonVisible = true
                self.presentationMode.wrappedValue.dismiss()
            }
        }.resume()
    }

    

    func saveProfile(){
        if let selectedImage = selectedImage{
            uploadImage(image: selectedImage)
        }
        else {
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(UserDefaultManager.UserAccessToken)"
            ]

            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(username.data(using: .utf8)!, withName: "name")
                    multipartFormData.append(dateFormatter.string(from: selectedDate).data(using: .utf8)!, withName: "dob")
                },
                to: "http://dinoreaders.com/api/profile/store", // Your API URL here
                method: .post,
                headers: headers
            )
            .validate(statusCode: 200..<300)
            .response { response in
                print(response)
                switch response.result {
                case .success:
                    self.presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print(error)
                    isButtonVisible = true
                }
            }
        }
    }
}

struct CreateNewProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewProfileView()
    }
}

struct MonthYearPicker: View {
    @Binding var selectedDate: Date

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    var body: some View {
        DatePicker(
            "Select a Month and Year",
            selection: $selectedDate,
            displayedComponents: .date
        )
        .labelsHidden()
        .datePickerStyle(WheelDatePickerStyle())
        .onChange(of: selectedDate) { newDate in
            // Optionally, you can perform some actions when the date is selected.
            // For example, you can update a ViewModel or send the selected date to a server.
        }
        .onAppear {
            // Customize the date picker's initial value and range as needed.
            // By default, the date picker will show the current date.
        }
    }
}
