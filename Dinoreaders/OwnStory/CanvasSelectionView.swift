import SwiftUI

struct CanvasSelectionView: View {
    
    @State var showTabBar : Bool = false
    
    let canvasData: [CanvasData] = [
        CanvasData(id: 1, name: "Design 1", thumbnail: "canvas_1", cover: "full_canvas_1"),
        CanvasData(id: 2, name: "Design 2", thumbnail: "canvas_2", cover: "full_canvas_2"),
        CanvasData(id: 3, name: "Design 3", thumbnail: "canvas_3", cover: "full_canvas_3")
    ]
    
    @Environment(\.presentationMode) var presentationMode

    
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
                    
                    
                    StrokeText(text: "Lets Begin!", width: 1.25, color: .black)
                        .font(.custom("Ruddy-Black", size: 32))
                        .foregroundColor(.white)
                
                    Spacer()
                }
                
                
                Text("Choose a design")
                    .foregroundColor(.white)
                    .font(.custom("Ruddy-Black", size: 20))
                    .padding(.horizontal, 13)
                    .background(.blue)
                    .cornerRadius(6.5)
                    .underline(true, color: .white)
                    .padding(.leading, 10)
                    .padding(.bottom, 8)
                    .padding(.top, 15)
                
                
                ScrollView(.vertical, showsIndicators: false)
                {
                    ForEach(canvasData, id: \.id){canvas in
                        NavigationLink(destination: CreateOwnStoryView(canvas: canvas)){
                            CanvasItemView(canvas: canvas)
                        }
                    }
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(showTabBar ? .visible: .hidden, for: .tabBar)
        .background(
            Image("home_gradient_bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        )
        .onAppear(){
            showTabBar = false
        }
        .onDisappear(){
            showTabBar = true
        }
    }
}


struct CanvasSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasSelectionView()
    }
}


struct CanvasItemView: View {
    var canvas: CanvasData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            Image(canvas.thumbnail)
                .resizable()
                .frame(width:UIScreen.main.bounds.width - 50, height: 165)
                .scaledToFill()
                .clipped()
                .padding(.vertical, 5)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                                .zIndex(1)
            Text(canvas.name)
                .font(.custom("Ruddy-Black", size: 16))
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 25)
        .padding(.bottom,15)
    }
}
