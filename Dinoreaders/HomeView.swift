//
//  HomeView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 18/09/23.
//

import SwiftUI

struct HomeView: View {
    
    init() {
        if #available(iOS 15, *) {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    var body: some View {
        TabView(){
            HomeTabView()
                .tabItem(){
                    Image(systemName: "phone.fill")
                    Text("Home")
                }
            LibraryTabView()
                .tabItem(){
                    Image(systemName: "person.2.fill")
                    Text("Library")
                }
            CreateTabView()
                .tabItem(){
                    Image(systemName: "slider.horizontal.3")
                    Text("Create")
                }
            SearchTabView()
                .tabItem(){
                    Image(systemName: "phone.fill")
                    Text("Search")
                }
        }
        .onAppear(){
            
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
