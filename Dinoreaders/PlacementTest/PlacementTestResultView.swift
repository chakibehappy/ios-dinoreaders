import SwiftUI

struct PlacementTestResultView: View {
    
    let book : SingleBook
    let readingLevel : Int
    let testResultMsg : String
    
    @EnvironmentObject var settings : UserSettings
    @State var isGoBackToMenu = false
    
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color(hex:"#35A8E7")
                    .edgesIgnoringSafeArea(.all)
                
                HStack(alignment: .center) {
                    VStack(alignment: .center) {
                        AsyncImage(url: URL(string: book.image_url)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 150, height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                    .shadow(radius: 10)
                                    .padding(.top, 20)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                    .shadow(radius: 10)
                                    .padding(.top, 20)
                            case .failure(let error):
                                Text("Error: \(error.localizedDescription)")
                            @unknown default:
                                Text("Unknown state")
                            }
                        }
                        
                        Text(book.title)
                            .font(.custom("Poppins-Black", size: 20))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 4)
                            .multilineTextAlignment(.center)
                            .frame(width: 220, alignment: .center)
                            .padding(.bottom, 16)
                    }
                    .padding()
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    VStack(alignment: .center){
                        Image("medal_1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .background(Color(.black.withAlphaComponent(0.05)))
                            .clipShape(Circle())
                            .padding(.bottom, 16)
                        
                        // Detail Text
                        Text(testResultMsg)
                            .font(.custom("Poppins-Bold", size: 20))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 4)
                            .multilineTextAlignment(.center)
                            .frame(width: 350, alignment: .center)
                            .padding(.bottom, 16)
                        
                        NavigationLink(destination: HomeTabView(), isActive:$isGoBackToMenu){
                            EmptyView()
                        }
                        Button(action: {
                            forcePortraitOrientation()
                            isGoBackToMenu = true
                        }) {
                            Text("Back to menu")
                                .font(.custom("Poppins-Bold", size: 20))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .background(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .shadow(radius: 10)
                        }
                        .background(Color("FF9800"))
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                    .padding()
                    .padding(.horizontal, 30)
                }
                .padding()
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .onAppear(){
                forceLandscapeOrientation()
            }
        }
    }
}

