//
//  ApplicationSettingView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 31/10/23.
//

import SwiftUI

struct ApplicationSettingView: View {
    
    @EnvironmentObject var settings : UserSettings
    @Environment(\.presentationMode) var presentationMode
    
    let dayOptions = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    @State private var isAutoCorrectOwnStory = false
    @State private var isShowBookByLevel = false
    @State private var isShowRecommendByLevel = false
    @State private var isSetTimeLimit = false
    @State private var selectedDays : String = "Daily"
    @State private var calculatedBy : String = "Each Login"
    @State private var selectedReadingTime : String = "30 Minutes"
    
    @State private var readingDays : [String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let calculatedByOptions = ["Each Login", "Total Logins"]
    let readingTimeOptions = ["30 Minutes", "1 Hour", "2 Hours", "3 Hours", "4 Hours", "5 Hours", "6 Hours"]
    
    @State private var readingProfiles : [ReadingProfile] = []
    @State private var selectedProfileId : Int = 0
    @State private var selectedProfileIndex : Int = 0
    
    init() {
       UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        NavigationStack(){
            ScrollView(.vertical){
                VStack(){
                    HStack{
                        Button( action: { self.presentationMode.wrappedValue.dismiss()})
                        {
                            Image("backarrow")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .scaledToFill()
                                .clipped()
                                .colorMultiply(.black)
                        }
                        Text("Settings")
                            .font(.custom("Quicksand-Bold", size: 20))
                            .padding(.horizontal, 15)
                        Spacer()
                    }
                    .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) { // Horizontal scroll view
                        HStack(spacing: 20) { // Arrange items horizontally
                            ForEach(readingProfiles.indices, id: \.self) { index in
                                let profile = readingProfiles[index]
                                SmallProfileImageButton(
                                    image: profile.profile[0].img_url,
                                    text:profile.profile[0].name,
                                    size:60,
                                    borderCol: selectedProfileId == profile.profile_id ? .yellow : .gray,
                                    action: {
                                        selectedProfileId = profile.profile_id
                                        selectedProfileIndex = index
                                        loadProfileSetting(profile: profile)
                                    }
                                )
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                        .padding(.horizontal, 25)
                        .padding(.bottom, 15)
                    }
                    
                    VStack(){
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 0.5)
                        Toggle("Auto correct for Create Your Own Story", isOn: $isAutoCorrectOwnStory)
                            .font(.custom("Quicksand-Bold", size: 16))
                            .padding(.vertical,10)
                            .padding(.horizontal,20)
                            .onChange(of: isAutoCorrectOwnStory) { newValue in
                                if readingProfiles[selectedProfileIndex].auto_correct_own_story != newValue {
                                    readingProfiles[selectedProfileIndex].auto_correct_own_story = newValue
                                    saveProfileSetting()
                                }
                            }
                    }
                    
                    VStack(){
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 0.5)
                        Toggle("Only show books based on Reading Level (or higher)", isOn: $isShowBookByLevel)
                            .font(.custom("Quicksand-Bold", size: 16))
                            .padding(.vertical,10)
                            .padding(.horizontal,20)
                            .onChange(of: isShowBookByLevel) { newValue in
                                if readingProfiles[selectedProfileIndex].book_by_reading_level != newValue {
                                    readingProfiles[selectedProfileIndex].book_by_reading_level = newValue
                                    saveProfileSetting()
                                }
                            }
                    }
                    
                    VStack(){
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 0.5)
                        Toggle("Only show recommend based on Reading Level (or higher)", isOn: $isShowRecommendByLevel)
                            .font(.custom("Quicksand-Bold", size: 16))
                            .padding(.vertical,10)
                            .padding(.horizontal,20)
                            .onChange(of: isShowRecommendByLevel) { newValue in
                                if readingProfiles[selectedProfileIndex].recommend_by_reading_level != newValue {
                                    readingProfiles[selectedProfileIndex].recommend_by_reading_level = newValue
                                    saveProfileSetting()
                                }
                            }
                    }
                    
                    VStack(){
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 0.5)
                        Toggle("Set time limit for access App", isOn: $isSetTimeLimit)
                            .font(.custom("Quicksand-Bold", size: 16))
                            .padding(.vertical,10)
                            .padding(.horizontal,20)
                            .onChange(of: isSetTimeLimit) { newValue in
                                if readingProfiles[selectedProfileIndex].set_limit_time != newValue {
                                    readingProfiles[selectedProfileIndex].set_limit_time = newValue
                                    saveProfileSetting()
                                }
                            }
                    }
                    
                    VStack(spacing: 0){
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 0.5)
                        
                        HStack(){
                            Text("Reading Day(s)")
                                .font(.system(size: 14))
                                .bold()
                            Spacer()
                            MultipleComboBoxView(
                                isEnable: $isSetTimeLimit,
                                resultLabel: $selectedDays,
                                selectedOption:$readingDays,
                                options: dayOptions,
                                onOptionSelected: {
                                    readingProfiles[selectedProfileIndex].reading_day = readingDays.joined(separator: ", ")
                                    saveProfileSetting()
                                }
                            )
                        }
                        .padding(.horizontal,20)
                        .opacity( isSetTimeLimit ? 1 : 0.5)
                        
                        HStack(){
                            Text("Calculated By")
                                .font(.system(size: 14))
                                .bold()
                            Spacer()
                            ComboBoxView(
                                isEnable: $isSetTimeLimit,
                                selectedOption: $calculatedBy,
                                options: calculatedByOptions,
                                onOptionSelected: {
                                    if let text = convertCalculatedByText(text: calculatedBy, isLabel: true) {
                                        readingProfiles[selectedProfileIndex].calculated_by = text
                                        saveProfileSetting()
                                    }
                                }
                            )
                        }
                        .padding(.horizontal,20)
                        .opacity( isSetTimeLimit ? 1 : 0.5)
                        
                        HStack(){
                            Text("Reading Time")
                                .font(.system(size: 14))
                                .bold()
                            Spacer()
                            ComboBoxView(
                                isEnable: $isSetTimeLimit,
                                selectedOption: $selectedReadingTime,
                                options: readingTimeOptions,
                                onOptionSelected: {
                                    if let text = convertReadingTimeText(text: selectedReadingTime, isLabel: true) {
                                        if let value = Int(text) {
                                            readingProfiles[selectedProfileIndex].reading_time = value
                                            saveProfileSetting()
                                        }
                                    }
                                }
                            )
                        }
                        .padding(.horizontal,20)
                        .opacity( isSetTimeLimit ? 1 : 0.5)
                        
                    }
                    
                    VStack(){
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 0.5)
                        HStack(){
                            NavigationLink(destination: PlacementTestLevelSelectView()){
                                Text("Placement Test")
                                    .font(.custom("Quicksand-Bold", size: 16))
                                    .padding(.vertical,10)
                            }
                            Spacer()
                        }
                        .padding(.horizontal,20)
                    }
                    Spacer()
                }
            }
        }
        .onAppear(){
            forcePortraitOrientation()
            getUserProfileSetting()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
    
    func getUserProfileSetting(){
        guard let url = URL(string: API.PROFILESETTING_API + String(UserDefaultManager.UserID)) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
                
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON string: \(jsonString)")
                }
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(ReadingProfileData.self, from: data)
                    if result.success == true {
                        DispatchQueue.main.async {
                            self.readingProfiles = result.data
                            selectedProfileId = readingProfiles[0].profile_id
                            loadProfileSetting(profile: readingProfiles[0])
                        }
                    }
                } catch {
                    print("Error decoding reading profiles data JSON: \(error)")
                }
            }
        }.resume()
    }
    
    func loadProfileSetting(profile : ReadingProfile)
    {
        isAutoCorrectOwnStory = profile.auto_correct_own_story
        isSetTimeLimit = profile.set_limit_time
        isShowBookByLevel = profile.book_by_reading_level
        isShowRecommendByLevel = profile.recommend_by_reading_level
        selectedDays = getShortDayNames(from: profile.reading_day)
        readingDays = profile.reading_day.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if let readingTime = convertReadingTimeText(text: String(profile.reading_time), isLabel: false) {
            selectedReadingTime = readingTime
        }
        if let calculatedText = convertCalculatedByText(text: String(profile.calculated_by), isLabel: false) {
            calculatedBy = calculatedText
        }
    }
    
    func saveProfileSetting()
    {
        let profile = readingProfiles[selectedProfileIndex]
        if profile.profile_id == settings.ReadingSetting.profile_id {
            settings.ReadingSetting = profile
        }
        guard let url = URL(string: API.SAVEPROFILESETTING_API) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONEncoder().encode(profile)
            request.httpBody = jsonData
        } catch {
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data {
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("Response JSON string: \(jsonString)")
//                }
//            }
        }.resume()
    }

}

struct ApplicationSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationSettingView()
    }
}


func getShortDayNames(from inputString: String) -> String {
    let dayMap: [String: String] = [
        "Monday": "Mon",
        "Tuesday": "Tue",
        "Wednesday": "Wed",
        "Thursday": "Thu",
        "Friday": "Fri",
        "Saturday": "Sat",
        "Sunday": "Sun"
    ]
    
    let orderedDays: [String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    func parseDays(from string: String) -> [String] {
        let dayNames = string.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        return dayNames
    }
    
    let inputDaysSet = Set(parseDays(from: inputString))
    
    if orderedDays.allSatisfy({ inputDaysSet.contains($0) }) {
        // If all days are present, return "Daily"
        return "Daily"
    } else {
        // Otherwise, map the full day names to short versions and order them based on `orderedDays`
        let shortDayNames = orderedDays
            .filter { inputDaysSet.contains($0) }
            .compactMap { dayMap[$0] }
        
        return shortDayNames.joined(separator: ", ")
    }
}

func convertCalculatedByText(text: String, isLabel: Bool) -> String? {
    let valueToLabel = [
        "Each Login For": "Each Login",
        "Total Logins For": "Total Logins"
    ]
    let labelToValue = [
        "Each Login": "Each Login For",
        "Total Logins": "Total Logins For"
    ]
    
    if isLabel {
        return labelToValue[text]
    } else {
        return valueToLabel[text]
    }
}


func convertReadingTimeText(text: String, isLabel: Bool) -> String? {
    let valueToLabel = [
        "30": "30 Minutes",
        "60": "1 Hour",
        "120": "2 Hours",
        "180": "3 Hours",
        "240": "4 Hours",
        "300": "5 Hours",
        "360": "6 Hours"
    ]
    let labelToValue = [
        "30 Minutes": "30",
        "1 Hour": "60",
        "2 Hours": "120",
        "3 Hours": "180",
        "4 Hours": "240",
        "5 Hours": "300",
        "6 Hours": "360"
    ]
    
    if isLabel {
        return labelToValue[text]
    } else {
        return valueToLabel[text]
    }
}


struct ComboBoxView: View {
    @State private var isShowingOptions = false
    @Binding var isEnable : Bool
    @Binding var selectedOption : String
    let options: [String]
    let onOptionSelected: () -> Void // Callback closure
    
    var body: some View {
        VStack {
            Button(action: {
                if isEnable{
                    isShowingOptions.toggle()
                }
            }) {
                HStack {
                    Text(selectedOption)
                        .foregroundColor(.black)
                        .font(.system(size: 14))
                    Image(systemName: "chevron.down.circle")
                        .foregroundColor(.black)
                }
            }
            .popover(isPresented: $isShowingOptions) {
                List(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                        isShowingOptions.toggle()
                        onOptionSelected()
                    }) {
                        Text(option)
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .padding()
    }
}

struct MultipleComboBoxView: View {
    @State private var isShowingOptions = false
    @Binding var isEnable : Bool
    @Binding var resultLabel: String
    @Binding var selectedOption: [String]
    let options: [String]
    let onOptionSelected: () -> Void

    var body: some View {
        ZStack {
            Button(action: {
                if isEnable {
                    isShowingOptions.toggle()
                }
            }) {
                HStack {
                    Text(resultLabel)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.black)
                        .font(.system(size: 14))
                    Image(systemName: "chevron.down.circle")
                        .foregroundColor(.black)
                }
            }
            .popover(isPresented: $isShowingOptions) {
                List(options, id: \.self) { option in
                    Button(action: {
                        if selectedOption.contains(option) {
                            selectedOption.removeAll { $0 == option }
                        } else {
                            selectedOption.append(option)
                        }
                        resultLabel = getShortDayNames(from: selectedOption.joined(separator: ", "))
                    }) {
                        HStack() {
                            Text(option)
                                .foregroundColor(.black)
                            if selectedOption.contains(option) {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                Button(action: {
                    isShowingOptions.toggle()
                    onOptionSelected()
                }) {
                    Text("Confirm")
                        .foregroundColor(.black)
                        .font(.system(size: 18))
                        .bold()
                        .padding()
                }
            }
        }
        .padding()
    }
}

struct SmallProfileImageButton: View {
    var image: String
    var text : String
    var size: CGFloat
    var borderCol : Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(){
                AsyncImage(url: URL(string: image)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                            .background(Color.white)
                            .overlay(Circle().stroke(borderCol, lineWidth: 3)) // Border
                            .clipped()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                            .background(Color.white)
                            .overlay(Circle().stroke(borderCol, lineWidth: 3)) // Border
                            .clipped()
                    case .failure(_):
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                            .background(Color.white)
                            .overlay(Circle().stroke(borderCol, lineWidth: 3)) // Border
                            .clipped()
                    @unknown default:
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                            .background(Color.white)
                            .overlay(Circle().stroke(borderCol, lineWidth: 3)) // Border
                            .clipped()
                        
                    }
                }
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(Circle().stroke(borderCol, lineWidth: 3)) // Border
                
                Text(text)
                    .font(.custom("Quicksand-Bold", size: 13))
            }
        }
    }
}


