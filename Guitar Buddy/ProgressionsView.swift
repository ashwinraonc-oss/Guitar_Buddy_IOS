//
//  Untitled.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/8/26.
//

import AVFoundation
import SwiftUI
import Combine

struct ProgressionView: View {
    @ObservedObject var progression: ProgressionController
    @State private var selectedRoot = "A"
    @State private var selectedQuality = "major"
    @State private var displayedProgressions: [ProgressionResult] = []
    @StateObject private var chordPlayer = ChordPlayer()
    
    
//    let xScale = w / 390
//    let yScale = h / 844
    
    let rootOptions = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#","A", "A#", "B"]
    let qualityOptions = ["major", "maj7", "minor", "min7"]
    
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    var body: some View {
        VStack(spacing:55){
            VStack{
                Text("Create")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(red: 88/255, green: 217/255, blue: 99/255).opacity(1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .padding(.bottom, 5)
                    .padding(.top, 10)
                HStack{
                    Picker("Root", selection: $selectedRoot){
                        ForEach(rootOptions, id: \.self){ root in
                            Text(root)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color(red: 255/255, green: 245/255, blue: 220/255))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 1)
                                .background(Color(red: 144/255, green: 213/255, blue: 255/255))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                .tag(root)
                        }
                    }
                    .pickerStyle(.wheel)
                    Picker("Quality", selection: $selectedQuality){
                        ForEach(qualityOptions, id: \.self){ quality in
                            Text(quality)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color(red: 255/255, green: 245/255, blue: 220/255))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 2)
                                .background(Color(red: 250/255, green: 80/255, blue: 83/255))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                .tag(quality)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                let maxChordsInProgression = 9
                Button{
                    guard progression.progression.count < maxChordsInProgression else { return }
                    let chord = Chord(root: selectedRoot, quality: selectedQuality)
                    progression.selectChord(chord)
//                    if displayedProgressions.isEmpty {
//                        displayedProgressions = Array(progression.suggestedProgressions.shuffled().prefix(5))
//                    }
                    
                }label: {
                    Text("Add Chord to Progression")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(red: 88/255, green: 217/255, blue: 99/255).opacity(1))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                .padding(.bottom, 2)
                .padding(.top, 10)
                .opacity(progression.progression.count >= maxChordsInProgression ? 0.4 : 1.0)
            }
            .frame(height: 220)
            .clipped()
            ZStack(alignment: .bottom) {
                VStack(spacing: 25) {
//                    Text("Current Progression:")
//                        .foregroundStyle(Color.black)
//                        .bold()
                    GeometryReader { geo in
                        let itemsPerRow = 3
                        let rowCount = max(1, Int(ceil(Double(progression.progression.count) / Double(itemsPerRow))))
                        let itemWidth = geo.size.width / CGFloat(itemsPerRow)
                        let itemHeight = geo.size.height / CGFloat(rowCount)

                        // reference sizes at scale = 1: stringSpacing 20, label 20pt, button 24pt
                        let referenceWidth: CGFloat = 200   // stringSpacing(20) * 10
                        let referenceHeight: CGFloat = 255  // label + diagram + button at reference scale
                        let scale = max(min(itemWidth / referenceWidth, itemHeight / referenceHeight), 0.3)

                        let stringSpacing = 20 * scale
                        let fretSpacing = 30 * scale
                        let labelFontSize = 30 * scale
                        let buttonIconSize = 30 * scale

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: itemsPerRow), spacing: 4) {
                            ForEach(Array(progression.progression.enumerated()), id: \.offset) { index, chord in
                                if let voicings = progression.chordVoicings[chord.name],
                                   let first = voicings.first {
                                    VStack(spacing: 4 * scale) {
                                        Text(chord.name)
                                            .foregroundStyle(Color.black)
                                            .bold()
                                            .font(Font.system(size: labelFontSize))
                                        FretBoardDiagramView(fretArray: first, stringSpacing: stringSpacing, fretSpacing: fretSpacing, dotColor: .red)
                                            .fixedSize()
                                            .padding(-4)
                                            .background(Color(red: 255/255, green: 199/255, blue: 55/255))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.black, lineWidth: 3)
                                            )

                                        Button {                                          // ← add from here
                                            chordPlayer.playChord(fretArray: first)
                                        } label: {
                                            Image(systemName: "play.circle.fill")
                                                .font(.system(size: buttonIconSize))
                                                .foregroundStyle(.black)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 255)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                VStack(alignment: .center) {
    //                Text("Suggested Chords:")
    //                    .foregroundStyle(Color.black)
    //                    .bold()
    //                LazyVGrid(columns: columns) {
    //                    ForEach(progression.suggestions, id: \.chord.name) { suggestion in
    //                        Button(suggestion.chord.name) {
    //                            progression.selectChord(suggestion.chord)
    //                        }
    //                    }
    //                }
                    Text("Recommended Progressions:")
                        .font(.system(size: 18,weight: .bold))
                        .foregroundStyle(Color.black)
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(red: 255/255, green: 199/255, blue: 55/255))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 3)
                        )
                    ZStack(alignment: .top) {
                        Canvas { context, size in
                            let lineColor = Color(red: 140/255, green: 120/255, blue: 80/255)
                            let rowHeight = size.height / 5
                            for i in 1...5 {
                                let y = rowHeight * CGFloat(i)
                                var path = Path()
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: size.width, y: y))
                                context.stroke(path, with: .color(lineColor), lineWidth: 1)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(progression.suggestedProgressions, id: \.templateName) { result in
                                    Text(result.chords.map { $0.name }.joined(separator: ", "))
                                        .foregroundStyle(Color.black)
                                        .frame(maxWidth: .infinity, minHeight: 28, alignment: .center)
                                        .padding(.horizontal, 8)
                                        .bold()
                                }
                            }
                        }
                        .frame(height: 140)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 60)
                Button {
                    progression.reset()
                    progression.suggestedProgressions = []
                    displayedProgressions = []
                }label: {
                    Text("Reset")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(red: 235/255, green: 51/255, blue: 34/255).opacity(1))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.background(Color(red: 255/255, green: 245/255, blue: 220/255).ignoresSafeArea())
    }

}

#Preview {
    ProgressionView(progression: ProgressionController())
}
