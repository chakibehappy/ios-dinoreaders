import SwiftUI
import UIKit

struct DinoEggsCollectionView: View {
    
    let screenBg : Color = Color(red: 1, green: 217/255, blue: 102/255)
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var dinoEggs : [DinoEgg] = []
    

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
                    StrokeText(text: "Dino Collection", width: 2, color: .black)
                        .font(.custom("Ruddy-Bold", size: 36))
                        .foregroundColor(.white)
                        .padding(.leading, -40)
                    Spacer()
                }
                .padding(.horizontal, 10)
                
                VStack(){
                    ScrollView(.vertical, showsIndicators: false)
                    {
                        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 0) {
                            ForEach(dinoEggs, id: \.id){ egg in
                                Button(action:{
                                    
                                }){
                                    AsyncImage(url: URL(string: egg.image_url)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: egg.status == "egg" ? 64 : 100, height: egg.status == "egg" ? 64 : 100)
                                                .clipped()
                                        case .failure(let error):
                                            Text("Error: \(error.localizedDescription)")
                                        @unknown default:
                                            Text("Unknown state")
                                        }
                                    }
                                }
                                .frame(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.width/3)
                            }
                        }
                    }
                }
                .frame(maxWidth:.infinity, maxHeight:.infinity)
                .padding(.top, 15)
                .ignoresSafeArea()
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .background(screenBg)
        .onAppear(){
            GetDinoEggsData()
        }
        .onDisappear(){}
    }
    
    func GetDinoEggsData(){
        guard let url = URL(string: API.GETDINO_EGG_COLLECTION_API) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
                
        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let response = response as? HTTPURLResponse {
//                        print("Response status code: \(response.statusCode)")
//                        print("Response headers: \(response.allHeaderFields)")
//                    }
            
            if let data = data {
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("Response JSON string: \(jsonString)")
//                }
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(DinoEggData.self, from: data)
                    DispatchQueue.main.async {
                        if result.success == true {
                            self.dinoEggs = result.data
                        }
                    }
                } catch {
                    print("Error decoding Dino Eggs data JSON: \(error)")
                }
            }

        }.resume()
    }
}


struct DinoEggsCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        DinoEggsCollectionView()
    }
}

