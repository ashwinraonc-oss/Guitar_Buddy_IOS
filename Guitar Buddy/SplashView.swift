//
//  SplashView.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/11/26.
//

import UIKit
import Foundation
import SwiftUI
import Lottie

struct SplashView: View {
    var body: some View {
        GeometryReader { geo in
            let yScale = geo.size.height / 844

            ZStack {
                Color(red: 210/255, green: 125/255, blue: 45/255)
                    .ignoresSafeArea()

                LottieView(animation: .named("player music"))
                    .playing()
                    .looping()
                    .resizable()
                    .offset(y: -10 * yScale)
            }
        }
    }
}

#Preview {
    SplashView()
}
