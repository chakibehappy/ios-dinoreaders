//
//  DinoreadersApp.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 18/09/23.
//

import SwiftUI

@main
struct DinoreadersApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(UserSettings())
                .environmentObject(ReadingTimeManager())
        }
    }
}

func forceLandscapeOrientation() {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
    }
}

func forcePortraitOrientation() {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
    }
}
