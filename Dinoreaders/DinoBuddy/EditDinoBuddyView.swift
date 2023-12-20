import SwiftUI
import UIKit

struct EditDinoBuddyView: View {
    
    @State var showTabBar : Bool = false
    let screenBg : Color = Color(red: 103/255, green: 224/255, blue: 147/255)
    let tabBodyColor  = Color(red: 171/255, green: 231/255, blue: 255/255)
    let activeHeaderColor  = "#58cefe"
    let unactiveHeaderColor  = "#CCCCCC"
    
    let canvasData: [CanvasData] = [
        CanvasData(id: 1, name: "Design 1", thumbnail: "canvas_1", cover: "full_canvas_1"),
        CanvasData(id: 2, name: "Design 2", thumbnail: "canvas_2", cover: "full_canvas_2"),
        CanvasData(id: 3, name: "Design 3", thumbnail: "canvas_3", cover: "full_canvas_3")
    ]
    
    @Environment(\.presentationMode) var presentationMode
    let yellow : Color = Color(red:254/255, green: 242/255, blue:0)
    let yellowGradients: [Color] = [
        Color(red:1, green: 168/255, blue:1/255),
        Color(red:1, green: 213/255, blue:1/255),
        Color.white
    ]
    
    @State var selectedtab = 0
    
    @State var avatars : [AvatarIconData] = [
        AvatarIconData(id: 1, name: "T-Rex", local_path: "", asset_name: "t_rex", img_url: ""),
        AvatarIconData(id: 2, name: "Brachiosaurus", local_path: "", asset_name: "brachiosaurus", img_url: ""),
        AvatarIconData(id: 3, name: "Hadrosaurus", local_path: "", asset_name: "hadrosaurus", img_url: ""),
        AvatarIconData(id: 4, name: "Spinosaurus", local_path: "", asset_name: "spinosaurus", img_url: ""),
        AvatarIconData(id: 5, name: "Plesiosaurus", local_path: "", asset_name: "plesiosaurus", img_url: ""),
        AvatarIconData(id: 6, name: "Ankylosaurus", local_path: "", asset_name: "ankylosaurus", img_url: ""),
        AvatarIconData(id: 7, name: "Dimetrodon", local_path: "", asset_name: "dimetrodon", img_url: ""),
        AvatarIconData(id: 8, name: "Styracosaurus", local_path: "", asset_name: "styracosaurus", img_url: ""),
        AvatarIconData(id: 9, name: "Stegosaurus", local_path: "", asset_name: "stegosaurus", img_url: ""),
        AvatarIconData(id: 10, name: "Kentrosaurus", local_path: "", asset_name: "kentrosaurus", img_url: ""),
        AvatarIconData(id: 11, name: "Dilophosaurus", local_path: "", asset_name: "dilophosaurus", img_url: ""),
        AvatarIconData(id: 12, name: "Triceratops", local_path: "", asset_name: "triceratops", img_url: "")
    ]
    @State var accessorys : [AvatarAccessoryData] = [
        AvatarAccessoryData(id: 1, local_path: "", asset_name: "avatar_frame_1", img_url: ""),
        AvatarAccessoryData(id: 2, local_path: "", asset_name: "avatar_frame_2", img_url: ""),
        AvatarAccessoryData(id: 3, local_path: "", asset_name: "avatar_frame_3", img_url: "")
    ]
    @State var backgrounds : [AvatarBackgroundData] = [
        AvatarBackgroundData(id: 1, color: "#FFB441", img_url: ""),
        AvatarBackgroundData(id: 2, color: "#FEF200", img_url: ""),
        AvatarBackgroundData(id: 3, color: "#0054A5", img_url: ""),
        AvatarBackgroundData(id: 4, color: "#67E093", img_url: ""),
        AvatarBackgroundData(id: 5, color: "#FF6060", img_url: ""),
        AvatarBackgroundData(id: 6, color: "#00D5D3", img_url: "")
    ]
    
    @State var selectedAvatar : AvatarIconData?
    @State var selectedAccessory : AvatarAccessoryData?
    @State var selectedBackground : AvatarBackgroundData = AvatarBackgroundData(id: 1, color: "#FFB441", img_url: "")
    
    var body: some View {
        
        NavigationStack{
            VStack(alignment: .leading, spacing: 0){
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
                    StrokeText(text: "Dino Buddy", width: 1.25, color: .black)
                        .font(.custom("Ruddy-Bold", size: 38))
                        .foregroundColor(.white)
                        .padding(.leading, -55)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.top, 15)
                
                HStack{
                    Spacer()
                    VStack(){
                        
                        ZStack(){
                            if let acc = selectedAccessory
                            {
                                Image(acc.asset_name)
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width/2 - 50, height:UIScreen.main.bounds.width/2 - 50)
                            }
                            else{
                                Image(accessorys[0].asset_name)
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width/2 - 50, height:UIScreen.main.bounds.width/2 - 50)
                            }
                        
                            if let avatar = selectedAvatar
                            {
                                Image(avatar.asset_name)
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width/2, height:UIScreen.main.bounds.width/2)
                                    .padding(.all, 10)
                            }
                            else{
                                Image(avatars[0].asset_name)
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width/2, height:UIScreen.main.bounds.width/2)
                                    .padding(.all, 10)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width/2, height:UIScreen.main.bounds.width/2)
                        .background(Color(hex:selectedBackground.color))
                        .clipShape(Circle())
                        .padding(.all,10)
                        .padding(.top,10)
                        
                        GradientViewButton(width:130, text: "Save!", btnCol: yellow, colors: yellowGradients, textSize: 24)
                    }
                    Spacer()
                }
                
                HStack(spacing: 0){
                    Button(action: {
                        selectedtab = 0
                    }){
                        StrokeText(text: "Choose a Friend!", width: 1.25, color: .black)
                            .font(.custom("Ruddy-Black", size: 18))
                            .foregroundColor(.white)
                    }
                    .frame(width: UIScreen.main.bounds.width/3, height: 60)
                    .background(Color(hex: selectedtab == 0 ? activeHeaderColor : unactiveHeaderColor))
                    .border(.black, width: 0.5)
                    
                    Button(action: {
                        selectedtab = 1
                    }){
                        StrokeText(text: "Accessory", width: 1.25, color: .black)
                            .font(.custom("Ruddy-Black", size: 18))
                            .foregroundColor(.white)
                    }
                    .frame(width: UIScreen.main.bounds.width/3, height: 60)
                    .background(Color(hex: selectedtab == 1 ? activeHeaderColor : unactiveHeaderColor))
                    .border(.black, width: 0.5)
                
                    Button(action: {
                        selectedtab = 2
                    }){
                        StrokeText(text: "Background!", width: 1.25, color: .black)
                            .font(.custom("Ruddy-Black", size: 18))
                            .foregroundColor(.white)
                    }
                    .frame(width: UIScreen.main.bounds.width/3, height: 60)
                    .background(Color(hex: selectedtab == 2 ? activeHeaderColor : unactiveHeaderColor))
                    .border(.black, width: 0.5)
                }
                .frame(width: UIScreen.main.bounds.width, height: 60)
                .background(tabBodyColor)
                .padding(.top, 15)
                
                VStack(){
                    ScrollView(.vertical, showsIndicators: false)
                    {
                        if(selectedtab == 0)
                        {
                            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 0) {
                                ForEach(avatars, id: \.id){ avatar in
                                    Button(action:{
                                        selectedAvatar = avatar
                                    }){
                                        Image(avatar.asset_name)
                                            .resizable()
                                            .frame(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.width/3)
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                        
                        if(selectedtab == 1)
                        {
                            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 0) {
                                ForEach(accessorys, id: \.id){ acc in
                                    Button(action:{
                                        selectedAccessory = acc
                                    }){
                                        VStack()
                                        {
                                            
                                                VStack(){
                                                    Image(acc.asset_name)
                                                        .resizable()
                                                        .frame(width: 75, height: 75)
                                                        
                                                }
                                                .frame(width: 100, height: 100)
                                                .background(selectedAccessory?.id == acc.id ? .yellow : tabBodyColor)
                                                .cornerRadius(50)
                                                
                                        }
                                        .frame(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.width/3)
                                        
                                    }
                                }
                            }
                        }
                        
                        if(selectedtab == 2)
                        {
                            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 0) {
                                ForEach(backgrounds, id: \.id){ bg in
                                    Button(action:{
                                        selectedBackground = bg
                                    }){
                                        VStack(){
                                            VStack(){
                                                
                                            }
                                            .frame(width: 80, height: 80)
                                            .background(Color(hex:bg.color))
                                            .cornerRadius(40)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.black, lineWidth: selectedBackground.color == bg.color ? 5 : 0)
                                            )
                                        }
                                        .frame(width: UIScreen.main.bounds.width/3 - 20, height: UIScreen.main.bounds.width/3 - 20)
                                        .padding(.top, 10)
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (UIScreen.main.bounds.width/2 + 320))
                .background(tabBodyColor)
                .ignoresSafeArea()
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(showTabBar ? .visible: .hidden, for: .tabBar)
        .background(screenBg)
        .onAppear(){
            showTabBar = false
        }
        .onDisappear(){
            showTabBar = true
        }
    }
}


struct EditDinoBuddyView_Previews: PreviewProvider {
    static var previews: some View {
        EditDinoBuddyView()
    }
}
