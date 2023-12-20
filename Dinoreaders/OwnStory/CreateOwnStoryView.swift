import Foundation
import SwiftUI

struct CreateOwnStoryView: View {
    
    @State var showTabBar : Bool = false
    
    let canvas : CanvasData?
    
    @Environment(\.presentationMode) var presentationMode

    @State var showDeleteButton = false
    @State var showNextButton = false
    @State var showPrevButton = false
    @State var showEditButton = false
    @State var showSaveButton = false
    
    var body: some View {
        NavigationStack{
            ZStack()
            {
                if let canvasData = canvas{
                    Image(canvasData.cover)
                        .resizable()
                        .frame(width:UIScreen.main.bounds.height - 350, height: UIScreen.main.bounds.width - 40)
                        .scaledToFill()
                        .clipped()
                }
                
                VStack(){
                    Text("Speak to record and wait while system recognize the voice.")
                        .font(.custom("Ruddy-Bold", size: 18))
                        .lineSpacing(0)
                        .foregroundColor(.blue)
                        .padding()
                        .padding(.trailing, 95)
                        .padding(.leading, 55)
                        .padding(.top, 55)
                    Spacer()
                }
                .frame(width:UIScreen.main.bounds.height - 350, height: UIScreen.main.bounds.width - 40)
                
                VStack(){
                    StrokeText(text: "Lets create a story", width: 2.5, color: .black)
                        .font(.custom("Ruddy-Black", size: 28))
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(width:UIScreen.main.bounds.height - 350, height: UIScreen.main.bounds.width - 40)
                
                VStack(alignment: .leading, spacing:0){
                    HStack{
                        Spacer()
                        Button( action: { self.presentationMode.wrappedValue.dismiss()})
                        {
                            Image("btn_add_cover")
                                .resizable()
                                .frame(width: 90, height: 90)
                                .scaledToFill()
                                .clipped()
                        }
                        .padding()
                        .padding(.top,10)
                    }
                    Spacer()
                    HStack{
                        Button( action: {
                        })
                        {
                            Image("btn_speak_new")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .scaledToFill()
                                .clipped()
                        }
                        .padding(.horizontal, 10)
                        Button( action: {
                        })
                        {
                            Image("btn_listen_new")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .scaledToFill()
                                .clipped()
                        }
                        Spacer()
                        if (showDeleteButton)
                        {
                            Button( action: {
                            })
                            {
                                Image("btn_delete_page")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .scaledToFill()
                                    .clipped()
                            }
                            .padding()
                        }
                    }
                }
                .frame(width:UIScreen.main.bounds.height - 350, height: UIScreen.main.bounds.width - 10)
                
                VStack(alignment: .leading, spacing:0){
                    Spacer()
                    HStack{
                        if(showPrevButton){
                            Button( action: {
                            })
                            {
                                Image("btn_back_page")
                                    .resizable()
                                    .frame(width: 80, height: 108)
                                    .padding()
                            }
                            .padding(.horizontal, 10)
                        }
                        Spacer()
                        if(showNextButton){
                            Button( action: {
                            })
                            {
                                Image("btn_next_page")
                                    .resizable()
                                    .frame(width: 80, height: 108)
                                    .padding()
                            }
                        }
                    }
                }
                .frame(width:UIScreen.main.bounds.height - 10, height: UIScreen.main.bounds.width - 10)
                
                HStack(spacing:0){
                    Spacer()
                    VStack(spacing:0){
                        if(showSaveButton){
                            Button( action: {
                            })
                            {
                                Image("btn_save_story")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                            }
                            .padding(.horizontal, 10)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        }
                        
                        if(showEditButton){
                            Button( action: {
                                
                            })
                            {
                                Image("btn_edit_story")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                            }
                            .padding(.top, 10)
                            Spacer()
                        }
                    }
                }
                .frame(width:UIScreen.main.bounds.height - 10, height: UIScreen.main.bounds.width - 10)
                
                // Close Button
                VStack(alignment: .leading, spacing:0){
                    HStack{
                        Button( action: { self.presentationMode.wrappedValue.dismiss()})
                        {
                            Image("close_icon")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .scaledToFill()
                                .clipped()
                        }
                        .padding(.all, 25)
                        Spacer()
                    }
                    Spacer()
                }
                
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(showTabBar ? .visible: .hidden, for: .tabBar)
        .background(.green)
        .onAppear(){
            showTabBar = false
            forceLandscapeOrientation()
        }
        .onDisappear(){
            showTabBar = true
            forcePortraitOrientation()
        }
    }
}


struct CreateOwnStoryView_Previews: PreviewProvider {
    static var previews: some View {
        CreateOwnStoryView(canvas : nil)
    }
}
