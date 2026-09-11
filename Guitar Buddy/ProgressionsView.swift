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
                progression.selectChord(chord)
            }
            Text("Suggested Chords:")
                .foregroundStyle(Color.black)
                .bold()
            LazyVGrid(columns: columns) {
                ForEach(progression.suggestions, id: \.chord.name) { suggestion in
                    Button(suggestion.chord.name) {
                        progression.selectChord(suggestion.chord)
                    }
                }
            }
            Text("Possible Progressions:")
                .foregroundStyle(Color.black)
                .bold()
            ScrollView{
                ForEach(progression.suggestedProgressions, id: \.templateName) {result in
                    Text(result.chords.map {$0.name}.joined(separator: ", "))
                        .foregroundStyle(Color.black)
                }
            }
            Text("Current Progression:")
                .foregroundStyle(Color.black)
                .bold()
            Text("\(progression.progression.map { $0.name }.joined(separator: " → "))")
                .foregroundStyle(Color.black)
            
            Button("Reset"){
                progression.reset()
            }
        }
        .padding(.bottom, 300)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 255/255, green: 250/255, blue: 220/255).ignoresSafeArea())
    }
}

#Preview {
    ProgressionView(progression: ProgressionController())
}
