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
    @ObservedObject var Progression: ProgressionController
    
    @State private var selectedRoot = "A"
    @State private var selectedQuality = "major"
    
    let rootOptions = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
    let qualityOptions = ["major", "minor"]
    
    let columns = Array(repeating: GridItem(.flexible()), count: 5)
    var body: some View {
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
                Progression.selectChord(chord)
            }
            Text("Suggested Chords:")
                .foregroundStyle(Color.black)
            LazyVGrid(columns: columns) {
                ForEach(Progression.suggestions, id: \.chord.name) { suggestion in
                    Button(suggestion.chord.name) {
                        Progression.selectChord(suggestion.chord)
                    }
                }
            }
            Text("Current Progression:")
                .foregroundStyle(Color.black)
            Text("\(Progression.progression.map { $0.name }.joined(separator: " → "))")
                .foregroundStyle(Color.black)
            Button("Reset"){
                Progression.reset()
            }
        }
        .padding(.bottom, 350)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 255/255, green: 250/255, blue: 220/255).ignoresSafeArea())
    }
}

#Preview {
    ProgressionView(Progression: ProgressionController())
}
