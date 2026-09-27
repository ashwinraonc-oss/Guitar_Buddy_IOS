//
//  Instructions.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/27/26.
//
import SwiftUI
import Lottie

struct instructionsView: View{
    var body: some View{
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let xScale = w / 390
            let yScale = h / 844
            ZStack{
                Color(red: 210/255, green: 125/255, blue: 45/255)
                    .ignoresSafeArea()
                VStack(spacing: 20){
                    Text("Instructions")
                        .font(.system(size: 30, weight: .bold))
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 0)
                        .background(Color(red: 88/255, green: 217/255, blue: 99/255))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .offset(y: -20)
                    Text("1. Click the black circle in the middle of the guitar to start recording")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 88/255, green: 217/255, blue: 99/255))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 3)
                        )
                    Text("2. Play each note of the chord separately (try muting each note right before playing the next)")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 88/255, green: 217/255, blue: 99/255))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 3)
                        )
                    Text("3. Let each note ring for 1-2 seconds")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 88/255, green: 217/255, blue: 99/255))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 3)
                        )
                    Text("4. Click the black circle again to stop recording")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 88/255, green: 217/255, blue: 99/255))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 3)
                        )
                    Text("5. Wait for the Chord Detector to detect")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 88/255, green: 217/255, blue: 99/255))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                .padding(.horizontal, 10)
                .offset(y: -40)
            }

        }
    }
}

#Preview {
    instructionsView()
}
    
    
