//
//  HomeView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 18/09/23.
//

import SwiftUI

struct HomeView: View {
    
    @State private var selection = 0
    
    init() {
        let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        //UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = UIColor(red:0.40, green: 0.87, blue: 0.57, alpha: 1)
        tabBarAppearance.backgroundColor = UIColor(red:0.40, green: 0.87, blue: 0.57, alpha: 1)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        TabView(selection : $selection){
            HomeTabView()
                .tabItem(){
                    Image(selection == 0 ? "home_menu_new_ui" : "home_menu_new_ui 1")
                        .resizable()
                        .scaledToFill()
                    //Text("Home")
                }
                .tag(0)
            LibraryTabView()
                .tabItem(){
                    Image(selection == 1 ? "library_menu_new" : "library_menu_new 1")
                        .resizable()
                        .scaledToFill()
                    //Text("Library")
                }
                .tag(1)
            CreateTabView()
                .tabItem(){
                    Image(selection == 2 ? "create_menu_new_ui" : "create_menu_new_ui 1")
                        .resizable()
                        .scaledToFill()
                    //Text("Create")
                }
                .tag(2)
            SearchTabView()
                .tabItem(){
                    Image(selection == 3 ? "search_menu_new_ui" : "search_menu_new_ui 1")
                        .resizable()
                        .scaledToFill()
                    //Text("Search")
                }
                .tag(3)
        }
        .onAppear(){}
        .navigationBarBackButtonHidden(true)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
