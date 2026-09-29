//
//  ElectricTunerView.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/29/26.
//

import AVFoundation
import SwiftUI
import Combine


struct ElectricTunerView: View {
    @ObservedObject var tuner: TunerController
    let noteAngles = [-75.0, -45.0, -15.0, 15.0, 45.0, 75.0]
    
    var body: some View{
        let scale = 1.6
        let arcDiameter = 250.0 * scale
        let labelRadius = 110 * scale
        let tickRadius = 95.0 * scale
        let needleLength = 90.0 * scale
        let centerOffset = 75.0 * scale
        var needleAngle: Double {
            let base = Double(0.0)
            let clampedCents = max(min(Double(tuner.chromaticCentsOff), 150), -150)   // clamp to ±1.5 semitones
            let offset = clampedCents * (15.0 / 150.0)                        // map ±150 cents → ±15°
            return base + offset
        }
        VStack{
            VStack {
                Text("Tuner")
                    .font(.system(size: 27, weight: .bold))
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
                ZStack{
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
                    NeedleShape()
                        .fill(Color.yellow)
                        .frame(width: 4, height: needleLength)
                        .rotationEffect(.degrees(needleAngle), anchor: .bottom)
                        .offset(y: centerOffset - needleLength / 2)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: needleAngle)
                }
                .frame(width: arcDiameter, height: arcDiameter / 2 + 5)
                HStack {
                    Text("\(tuner.detectedNote)")
                }
                .font(.system(size: 60, weight: .bold))
                .foregroundStyle(Color(.white))
                .offset(y: -10)
                Text(tuner.chromaticDirection)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(tuner.chromaticDirection == "In Tune!" ? Color(red: 88/255, green: 217/255, blue: 99/255) : .white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color(red: 191/255, green: 64/255, blue: 191/255).ignoresSafeArea())
    }
}

#Preview {
    ElectricTunerView(tuner: TunerController())
}
