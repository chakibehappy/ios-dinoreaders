//
//  ApplicationSettingView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 31/10/23.
//

import SwiftUI

struct ApplicationSettingView: View {
    @State private var isAutoCorrectOwnStory = false
    @State private var isShowBookByLevel = false
    @State private var isShowRecommendByLevel = false
    @State private var isSetTimeLimit = false
    let dayOptions = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let calculatedByOptions = ["Each Login", "Total Logins"]
    let readingTimeOptions = ["30 Minutes", "1 Hour", "2 Hours", "3 Hours", "4 Hours", "5 Hours", "6 Hours"]
    
    init() {
       UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        NavigationStack(){
            ScrollView(.vertical){
                VStack(){
                    HStack{
                        Text("Settings")
                            .font(.custom("Quicksand-Bold", size: 20))
                            .padding(.horizontal, 15)
                        Spacer()
                    }
                    
                    VStack(){
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 0.5)
                        Toggle("Auto correct for Create Your Own Story", isOn: $isAutoCorrectOwnStory)
                            .font(.custom("Quicksand-Bold", size: 16))
                            .padding(.vertical,10)
                            .padding(.horizontal,20)
                    }
                    
                    VStack(){
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 0.5)
                        Toggle("Only show books based on Reading Level (or higher)", isOn: $isShowBookByLevel)
                            .font(.custom("Quicksand-Bold", size: 16))
                            .padding(.vertical,10)
                            .padding(.horizontal,20)
                    }
                    
                    VStack(){
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 0.5)
                        Toggle("Only show recommend based on Reading Level (or higher)", isOn: $isShowRecommendByLevel)
                            .font(.custom("Quicksand-Bold", size: 16))
                            .padding(.vertical,10)
                            .padding(.horizontal,20)
                    }
                    
                    VStack(){
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 0.5)
                        Toggle("Set time limit for access App", isOn: $isSetTimeLimit)
                            .font(.custom("Quicksand-Bold", size: 16))
                            .padding(.vertical,10)
                            .padding(.horizontal,20)
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
                            MultipleComboBoxView(selectedOption:[ "Sunday", "Monday"], options: dayOptions)
                        }
                        .padding(.horizontal,20)
                        
                        HStack(){
                            Text("Calculated By")
                                .font(.system(size: 14))
                                .bold()
                            Spacer()
                            ComboBoxView(selectedOption: "Daily", options: calculatedByOptions)
                        }
                        .padding(.horizontal,20)
                        
                        
                        HStack(){
                            Text("Reading Time")
                                .font(.system(size: 14))
                                .bold()
                            Spacer()
                            ComboBoxView(selectedOption: "30 Minutes", options: readingTimeOptions)
                        }
                        .padding(.horizontal,20)
                        
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
        .navigationBarBackButtonHidden(false)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct ApplicationSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationSettingView()
    }
}

struct ComboBoxView: View {
    @State private var isShowingOptions = false
    @State var selectedOption : String
    let options: [String]
    
    var body: some View {
        VStack {
            Button(action: {
                isShowingOptions.toggle()
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
    @State var selectedOption: [String]
    let options: [String]

    var body: some View {
        ZStack {
            Button(action: {
                isShowingOptions.toggle()
            }) {
                HStack {
                    Text(selectedOption.joined(separator: ", "))
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


