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
    let qualityOptions = ["major", "minor"]
    
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    var body: some View {
        VStack(spacing:50){
            VStack{
                HStack{
                    Picker("Root", selection: $selectedRoot){
                        ForEach(rootOptions, id: \.self){ root in
                            Text(root).tag(root)
                                .foregroundStyle(Color.black)
                        }
                    }
                    .pickerStyle(.wheel)
                    Picker("Quality", selection: $selectedQuality){
                        ForEach(qualityOptions, id: \.self){ quality in
                            Text(quality).tag(quality)
                                .foregroundStyle(Color.black)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                Button("Add Chord"){
                    let chord = Chord(root: selectedRoot, quality: selectedQuality)
                    progression.selectChord(chord)
                    if displayedProgressions.isEmpty {
                        displayedProgressions = Array(progression.suggestedProgressions.shuffled().prefix(5))
                    }
                    
                }
            }
            .frame(height: 150)
            .clipped()
            ZStack(alignment: .bottom) {
                VStack(spacing: 10) {
    //            Text("Current Progression:")
    //                .foregroundStyle(Color.black)
    //                .bold()
    //                .padding()
    //            Text("\(progression.progression.map { $0.name }.joined(separator: " → "))")
    //                .foregroundStyle(Color.black)
    //                .font(.system(size: 30))
                    Text("Current Progression:")
                        .foregroundStyle(Color.black)
                        .bold()
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(progression.progression, id: \.name) { chord in
                                if let voicings = progression.chordVoicings[chord.name],
                                   let first = voicings.first {
                                    VStack {
                                        Text(chord.name)
                                            .foregroundStyle(Color.black)
                                            .bold()
                                            .font(Font.system(size: 20))
                                        FretBoardDiagramView(fretArray: first, stringSpacing: 15, fretSpacing: 25)
                                            .fixedSize()
                                            .background(Color(red: 210/255, green: 125/255, blue: 45/255).cornerRadius(8))
                                        Button {                                          // ← add from here
                                            chordPlayer.playChord(fretArray: first)
                                        } label: {
                                            Image(systemName: "play.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundStyle(.black)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 200)
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
                        .foregroundStyle(Color.black)
                        .bold()
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
                                ForEach(displayedProgressions, id: \.templateName) { result in
                                    Text(result.chords.map { $0.name }.joined(separator: ", "))
                                        .foregroundStyle(Color.black)
                                        .frame(maxWidth: .infinity, minHeight: 28, alignment: .center)
                                        .padding(.horizontal, 8)
                                }
                            }
                        }
                        .frame(height: 140)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 60)
                Button("Reset Progression") {
                    progression.reset()
                    displayedProgressions = []
                }
                    .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.background(Color(red: 255/255, green: 250/255, blue: 220/255).ignoresSafeArea())
    }

}

#Preview {
    ProgressionView(progression: ProgressionController())
}
