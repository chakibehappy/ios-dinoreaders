import SwiftUI

struct DinoEggsInfoView: View {
    let dinoEggs: [DinoEgg]
    @EnvironmentObject var settings: UserSettings
    @State private var eggIndex = 0
    @State private var infoText = ""
    @State private var imageUrl = ""
    @State private var goToHomePage = false
    
    init(dinoEggs: [DinoEgg]) {
        self.dinoEggs = dinoEggs
    }
    
    func displayDinoEggInfo() {
        guard eggIndex < dinoEggs.count else { return }
        let egg = dinoEggs[eggIndex]
        imageUrl = egg.image_url
        infoText = "You have earned a Dino Egg!\nKeep reading to hatch your Dino Egg."
        if egg.status == "baby" {
            if let name = egg.name {
                infoText = "Your Dino Egg is hatching!\nKeep reading to grow your baby \(name)."
            }
        } else if egg.status == "adult" {
            infoText = "Your Dino is growing up!\nCongratulations."
        }
    }
    
    var body: some View {
        if goToHomePage {
            HomeView()
        } else {
            NavigationStack {
                ZStack {
                    Color(hex: "#fbe5d6")
                    VStack {
                        VStack {
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .padding(.vertical, 14)
                                case .failure:
                                    Image("t_rex")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .padding(.vertical, 14)
                                @unknown default:
                                    Image("t_rex")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .padding(.vertical, 14)
                                }
                            }
                            Text(infoText)
                                .font(.custom("Poppins-Medium", size: 24))
                                .foregroundColor(Color(hex: "#333"))
                                .multilineTextAlignment(.center)
                                .padding(18)
                        }
                        .frame(maxWidth: .infinity)
                        Button(action: {
                            eggIndex += 1
                            if eggIndex < dinoEggs.count {
                                displayDinoEggInfo()
                            } else {
                                settings.showDinoEggWindow = false
                                goToHomePage = true
                            }
                        }) {
                            Image("next_arrow")
                                .resizable()
                                .frame(width: 64, height: 64)
                                .padding(.top, 20)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .edgesIgnoringSafeArea(.all)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .onAppear {
                forcePortraitOrientation()
                displayDinoEggInfo()
            }
        }
    }
}
