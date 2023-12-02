//
//  CreateNewProfileView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 01/11/23.
//
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
    
    func uploadProfileImage(name: String, dob: String, image: UIImage, completion: @escaping (Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: ["message": "Failed to create image data"]))
            return
        }
        
        let imageSizeInKB = Double(imageData.count) / 1024.0
        if imageSizeInKB > 2048 {
            // Display an error message to the user or prevent the upload
            print("Image size exceeds the limit")
            return
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaultManager.UserAccessToken)"
        ]

        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "img_url", fileName: "image.jpg", mimeType: "image/jpeg")
                multipartFormData.append(name.data(using: .utf8)!, withName: "name")
                multipartFormData.append(dob.data(using: .utf8)!, withName: "dob")
            },
            to: "http://dinoreaders.com/api/profile/store", // Your API URL here
            method: .post,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        .response { response in
            switch response.result {
            case .success:
                completion(nil) // Success
            case .failure(let error):
                completion(error) // Error
            }
        }
    }

    func saveProfile(){
        if let selectedImage = selectedImage{
            
            uploadProfileImage(name: username, dob: dateFormatter.string(from: selectedDate), image: selectedImage) { error in
                if let error = error {
                    print("Error uploading profile image: \(error)")
                    self.presentationMode.wrappedValue.dismiss()
                    // Handle the error as needed (e.g., show an alert)
                } else {
                    print("Profile image uploaded successfully")
                    self.presentationMode.wrappedValue.dismiss()
                    // Handle success as needed (e.g., navigate to a different view)
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
