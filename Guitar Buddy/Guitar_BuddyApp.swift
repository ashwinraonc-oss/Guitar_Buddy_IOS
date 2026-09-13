//
//  Guitar_BuddyApp.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 8/31/26.
//

import SwiftUI

@main
struct Guitar_BuddyApp: App {
    @State private var showSplash = true
    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                SplashView()
                    .ignoresSafeArea()
                    .opacity(showSplash ? 1 : 0)
                    .animation(.easeOut(duration: 0.5), value: showSplash)
                    .allowsHitTesting(showSplash)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSplash = false
                }
            }
        }
    }
}
