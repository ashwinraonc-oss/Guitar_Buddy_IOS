//
//  TunerView.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/4/26.
//

import AVFoundation
import SwiftUI
import Combine

struct NeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let tipLength = rect.height * 0.15   // only the top 15% tapers to a point

        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))                 // sharp tip
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + tipLength))  // where the straight shaft starts, right side
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))              // straight down the right side
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))              // straight across the bottom
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tipLength))  // straight up the left side
        path.closeSubpath()
        return path
    }
}
struct TunerView: View {
    @ObservedObject var tuner: TunerController
    @ObservedObject var player: ChordPlayer
    var needleAngle: Double {
        guard let idx = tuner.closestString else { return 0.0 }
        let base = -75.0 + 30.0 * Double(idx)
        let clampedCents = max(min(Double(tuner.centsOff), 150), -150)   // clamp to ±1.5 semitones
        let offset = clampedCents * (15.0 / 150.0)                        // map ±150 cents → ±15°
        return base + offset
    }

    var body: some View {
        let scale = 1.6
        let arcDiameter = 250.0 * scale
        let labelRadius = 110 * scale
        let tickRadius = 95.0 * scale
        let needleLength = 90.0 * scale
        let centerOffset = 75.0 * scale

        let guitarNotes = tuner.selectedTuning.stringNames
        let noteAngles = [-75.0, -45.0, -15.0, 15.0, 45.0, 75.0]
        VStack {
            VStack {
                Text("Tune")
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

//                    Capsule()
//                        .fill(Color.yellow)
//                        .frame(width: 4, height: needleLength)
//                        .rotationEffect(.degrees(needleAngle), anchor: .bottom)
//                        .offset(y: centerOffset - needleLength / 2)
//                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: needleAngle)
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
                .offset(y: -10)
                Text(tuner.tuningDirection)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(tuner.inTune ? Color(red: 88/255, green: 217/255, blue: 99/255) : .white)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: -13), count: 4), spacing: 10) {
                    Button {
                        tuner.selectedTuning = standardTuning
                        player.playMIDIUnsorted(midiArray: standardTuning.stringMIDI)
                    }label: {
                        Text("Standard")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.yellow))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .opacity(tuner.selectedTuning.name == "Standard" ? 0.5 : 1)
                    Button {
                        tuner.selectedTuning = dropDTuning
                        player.playMIDIUnsorted(midiArray: dropDTuning.stringMIDI)
                    }label: {
                        Text("Drop D")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.yellow))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .opacity(tuner.selectedTuning.name == "Drop D" ? 0.5 : 1)
                    Button {
                        tuner.selectedTuning = dadgadTuning
                        player.playMIDIUnsorted(midiArray: dadgadTuning.stringMIDI)
                    }label: {
                        Text("DADGAD")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.yellow))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .opacity(tuner.selectedTuning.name == "DADGAD" ? 0.5 : 1)
                    Button {
                        tuner.selectedTuning = dadfceTuning
                        player.playMIDIUnsorted(midiArray: dadfceTuning.stringMIDI)
                    }label: {
                        Text("DADFCE")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.yellow))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .opacity(tuner.selectedTuning.name == "DADFCE" ? 0.5 : 1)
                    Button {
                       
                    }label: {
                        Text("Half Step Down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.yellow))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .opacity(0)
                    Button {
                        tuner.selectedTuning = dropHalfStepTuning
                        player.playMIDIUnsorted(midiArray: dropHalfStepTuning.stringMIDI)
                    }label: {
                        Text("E Flat")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.yellow))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .opacity(tuner.selectedTuning.name == "Eb" ? 0.5 : 1)
                    Button {
                        tuner.selectedTuning = openGTuning
                        player.playMIDIUnsorted(midiArray: openGTuning.stringMIDI)
                    }label: {
                        Text("Open G")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.yellow))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .opacity(tuner.selectedTuning.name == "Open G" ? 0.5 : 1)
                }
                .padding(.horizontal, 10)
                .padding(.top, 50)
                .onAppear {
                    guard !ProcessInfo.processInfo.environment.keys.contains("XCODE_RUNNING_FOR_PREVIEWS") else { return }
                    tuner.startTuning()
                }
                .onDisappear {tuner.stopTuning()}
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .offset(y: 0)
        .background(Color(red: 191/255, green: 64/255, blue: 191/255).ignoresSafeArea())

    }

}

#Preview {
    TunerView(tuner: TunerController(), player: ChordPlayer())
}
