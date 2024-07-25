//
//  PlacementTestLevelSelectView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 01/11/23.
//

import SwiftUI

struct PlacementTestLevelSelectView: View {
    
    @Environment(\.presentationMode) var presentationMode
    	
    let bgColor : Color = Color(red:187/255, green: 222/255, blue:251/255)
    
    var body: some View {
        NavigationStack(){
            ZStack(){
                VStack(){
                    
                    HStack{
                        Button( action: {
                            self.presentationMode.wrappedValue.dismiss()
                            forcePortraitOrientation()
                        })
                        {
                            Image("backarrow")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .scaledToFill()
                                .clipped()
                                .padding(.vertical, 5)
                        }
                        Spacer()
                    }
                    .padding(.top, 35)
                    Spacer()
                }
                .frame(maxHeight:.infinity)
                
                HStack(spacing: 0){
                    VStack(){
                        VStack(alignment: .leading, spacing: 5){
                            
                            NavigationLink(destination: BookGradeSelectionView(reading_level: "8")){
                                HStack(){
                                    Text("Lvl 8 : Independent Reader")
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Bold", size: 13))
                                        .padding(.leading,15)
                                    Spacer()
                                }
                                .frame(width: 240)
                                .padding(.vertical, 10)
                                .padding(.leading,10)
                                .background(.yellow)
                                .cornerRadius(20)
                            }
                            
                            NavigationLink(destination: BookGradeSelectionView(reading_level: "7")){
                                HStack(){
                                    Text("Lvl 7 : Proficient Reader")
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Bold", size: 13))
                                        .padding(.leading,15)
                                    Spacer()
                                }
                                .frame(width: 240)
                                .padding(.vertical, 10)
                                .padding(.leading,10)
                                .background(.orange)
                                .cornerRadius(20)
                            }
                            
                            NavigationLink(destination: BookGradeSelectionView(reading_level: "6")){
                                HStack(){
                                    Text("Lvl 6 : Advanced Fluent Reader")
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Bold", size: 13))
                                        .padding(.leading,15)
                                    Spacer()
                                }
                                .frame(width: 240)
                                .padding(.vertical, 10)
                                .padding(.leading,10)
                                .background(.red)
                                .cornerRadius(20)
                            }
                            
                            NavigationLink(destination: BookGradeSelectionView(reading_level: "5")){
                                HStack(){
                                    Text("Lvl 5 : Fluent Reader")
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Bold", size: 13))
                                        .padding(.leading,15)
                                    Spacer()
                                }
                                .frame(width: 240)
                                .padding(.vertical, 10)
                                .padding(.leading,10)
                                .background(.pink)
                                .cornerRadius(20)
                            }
                            
                            
                            NavigationLink(destination: BookGradeSelectionView(reading_level: "4")){
                                HStack(){
                                    Text("Lvl 4 : Early Fluent Reader")
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Bold", size: 13))
                                        .padding(.leading,15)
                                    Spacer()
                                }
                                .frame(width: 240)
                                .padding(.vertical, 10)
                                .padding(.leading,10)
                                .background(.purple)
                                .cornerRadius(20)
                            }
                            
                            NavigationLink(destination: BookGradeSelectionView(reading_level: "3")){
                                HStack(){
                                    Text("Lvl 3 : Emergent Reader")
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Bold", size: 13))
                                        .padding(.leading,15)
                                    Spacer()
                                }
                                .frame(width: 240)
                                .padding(.vertical, 10)
                                .padding(.leading,10)
                                .background(.blue)
                                .cornerRadius(20)
                            }
                            
                            NavigationLink(destination: BookGradeSelectionView(reading_level: "2")){
                                HStack(){
                                    Text("Lvl 2 : Early Emergent Reader")
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Bold", size: 13))
                                        .padding(.leading,15)
                                    Spacer()
                                }
                                .frame(width: 240)
                                .padding(.vertical, 10)
                                .padding(.leading,10)
                                .background(.teal)
                                .cornerRadius(20)
                            }
                            
                            
                            NavigationLink(destination: BookGradeSelectionView(reading_level: "1")){
                                HStack(){
                                    Text("Lvl 1 : Pre-Reading")
                                        .foregroundColor(.white)
                                        .font(.custom("Ruddy-Bold", size: 13))
                                        .padding(.leading,15)
                                    Spacer()
                                }
                                .frame(width: 240)
                                .padding(.vertical, 10)
                                .padding(.leading,10)
                                .background(.green)
                                .cornerRadius(20)
                            }
                                                        
                            Spacer()
                        }
                        .padding(.top, 25)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    
                    
                    VStack(){
                        VStack(alignment: .leading, spacing: 0){
                            Text("Placement Test")
                                .foregroundColor(.white)
                                .font(.custom("Ruddy-Bold", size: 26))
                                .padding(.bottom, 10)
                                .padding(.top, 10)
                                .padding(.horizontal, 20)
                            
                            Text("Hello parents/guardians! Welcome to our placement test to help determine your child's reading capability!")
                                .foregroundColor(.white)
                                .font(.custom("Ruddy-Bold", size: 12))
                                .padding(.bottom, 8)
                                .padding(.horizontal, 20)
                            
                            Text("Ensuring that your child gets the best experience throughout their reading and learning journey on Dinoreader,")
                                .foregroundColor(.white)
                                .font(.custom("Ruddy-Bold", size: 12))
                                .padding(.bottom, 8)
                                .padding(.horizontal, 20)
                            
                            Text("We have broken down the different reading levels based on the (DRA) Development Reading Assesment.")
                                .foregroundColor(.white)
                                .font(.custom("Ruddy-Bold", size: 12))
                                .padding(.bottom, 8)
                                .padding(.horizontal, 20)
                            
                            Text("Levels are divided to categorise based on overall age and education levels as a base guide")
                                .foregroundColor(.white)
                                .font(.custom("Ruddy-Bold", size: 12))
                                .padding(.bottom, 8)
                                .padding(.horizontal, 20)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.blue)
                        .cornerRadius(15)
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .padding(.top,15)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bgColor)
            
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear(){
            forceLandscapeOrientation()
        }
    }
}

struct PlacementTestLevelSelectView_Previews: PreviewProvider {
    static var previews: some View {
        PlacementTestLevelSelectView()
    }
}
