//
//  TunerView.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/4/26.
//

import AVFoundation
import SwiftUI
import Combine

struct TunerView: View {
    @ObservedObject var tuner: TunerController
    var needleAngle: Double {
        guard tuner.detectedNote != "--" else { return 0.0 }
        let positions = ["A": -45.0, "D": -15.0, "G": 15.0, "B": 45.0]
        let base: Double
        if tuner.detectedNote == "E" {
            base = tuner.detectedFrequency > 250 ? 75.0 : -75.0
        } else {
            base = positions[tuner.detectedNote] ?? 0.0
        }
        return base + Double(tuner.centsOff) * 0.3
    }
    
    var body: some View{
        let scale = 1.6
        let arcDiameter = 250.0 * scale
        let labelRadius = 110 * scale
        let tickRadius = 95.0 * scale
        let needleLength = 90.0 * scale
        let centerOffset = 75.0 * scale

        let guitarNotes = ["E", "A", "D", "G", "B", "E"]
        let noteAngles = [-75.0, -45.0, -15.0, 15.0, 45.0, 75.0]
        VStack{
            VStack{
                Text("Tuner")
                    .font(.system(size: 30, weight: .bold))
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 0)
                    .background(Color.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 3)
                    )
                ZStack {
                    ForEach(0..<6, id: \.self) { i in
                        let angle = noteAngles[i] * .pi / 180
                        Text(guitarNotes[i])
                            .font(.system(size: 13 * scale, weight: .bold))
                            .foregroundColor(Color(red: 212/255, green: 230/255, blue: 135/255))
                            .offset(x: labelRadius * sin(angle), y: -labelRadius * cos(angle) + centerOffset)
                    }
                    let allTickAngles = stride(from: -85.0, through: 85.0, by: 5.0).map { $0 }
                    ForEach(0..<allTickAngles.count, id: \.self) { i in
                        let angle = allTickAngles[i] * .pi / 180
                        let isMajor = allTickAngles[i].truncatingRemainder(dividingBy: 30) == 0
                        let isMedium = allTickAngles[i].truncatingRemainder(dividingBy: 15) == 0
                        let tickHeight: Double = isMajor ? 14 * scale : (isMedium ? 8 * scale : 4 * scale)
                        Rectangle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 2, height: tickHeight)
                            .rotationEffect(.degrees(allTickAngles[i]))
                            .offset(x: tickRadius * sin(angle), y: -tickRadius * cos(angle) + centerOffset)
                    }
                    Circle()
                        .trim(from: 0.5, to: 1.0)
                        .stroke(Color.yellow, lineWidth: 2)
                        .frame(width: arcDiameter, height: arcDiameter)
                        .offset(y: centerOffset)

                    Capsule()
                        .fill(Color.yellow)
                        .frame(width: 4, height: needleLength)
                        .rotationEffect(.degrees(needleAngle), anchor: .bottom)
                        .offset(y: centerOffset - needleLength / 2)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: needleAngle)
                }
                .frame(width: arcDiameter, height: arcDiameter / 2 + 5)
                HStack{
                    Text("\(tuner.detectedNote)")
                }
                .font(.system(size: 60, weight: .bold))
                .offset(y:-10)
                .onAppear{
                    guard !ProcessInfo.processInfo.environment.keys.contains("XCODE_RUNNING_FOR_PREVIEWS") else { return }
                    tuner.startTuning()
                }
                .onDisappear {tuner.stopTuning()}
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .offset(y: -180)
        .background(Color(red: 191/255, green: 64/255, blue: 191/255).ignoresSafeArea())

    }
    

}

#Preview {
    TunerView(tuner: TunerController())
}
