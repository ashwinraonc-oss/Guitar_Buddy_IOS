//
//  PianoView.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/24/26.
//

//struct Key {
//    let position: Int
//    var active: Bool = false
//    let note: String
//    let MIDI: Int
//    var type: String {
//        switch MIDI%12 {
//        case let value where MIDI_Sharps.contains(MIDI % 12):  return "Black"
//        default:  return "White"
//        }
//    }
//}

import SwiftUI
import AVFoundation
import Combine

struct PianoView: View {
    @ObservedObject var recorder: AudioController
    @ObservedObject var keys: PianoController
    @ObservedObject var chordPlayer: ChordPlayer
    var keySpacing: Int = 20
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let xScale = w / 390
            let yScale = h / 844

            ZStack{
                Color(red: 210/255, green: 125/255, blue: 45/255)
                    .ignoresSafeArea()
                let canvasWidth: Int = keySpacing * 48
                VStack{
                HStack{
                    Canvas{context, size in
                        let availHeight = size.height
                        
                        let xs = keys.keyArray.map{key -> CGFloat in
                            let baseX = CGFloat(key.position * 40)
                            return key.type == "Black" ? baseX + 20 : baseX
                        }
                        guard let minX = xs.min(), let maxX = xs.max() else { return }
                        let totalWidth = maxX - minX
                        let centerOffset = (size.width - totalWidth) / 2 - minX
                        //white keys
                        for key in keys.keyArray where key.type != "Black" {
                            let baseX = CGFloat(key.position * 40) + centerOffset
                            let whiteKeyWidth: CGFloat = 40
                            let whiteKeyHeight: CGFloat = 200
                            let rect = CGRect(x: baseX - whiteKeyWidth / 2, y: 0, width: whiteKeyWidth, height: whiteKeyHeight)
                            let path = Path(roundedRect: rect, cornerRadius: 8)
                            
                            let fillColor = key.active
                            ? Color(red: 88/255, green: 217/255, blue: 99/255)   // same green ContentView uses for "active"/detected states
                            : Color(red: 237/255, green: 219/255, blue: 171/255) // same cream ContentView uses for the guitar's tuning pegs
                            
                            context.fill(path, with: .color(fillColor))
                            context.stroke(path, with: .color(.black), lineWidth: 3)
                        }
                        
                        //black keys
                        for key in keys.keyArray where key.type == "Black" {
                            let baseX = CGFloat(key.position * 40) + centerOffset
                            let blackKeyWidth: CGFloat = 20
                            let blackKeyHeight: CGFloat = 100
                            let rect = CGRect(x: baseX + 20 - blackKeyWidth / 2, y: 0, width: blackKeyWidth, height: blackKeyHeight)
                            let path = Path(roundedRect: rect, cornerRadius: 6)
                            
                            let fillColor = key.active
                            ? Color(red: 88/255, green: 217/255, blue: 99/255)
                            : Color(red: 14/255, green: 17/255, blue: 17/255)
                            
                            context.fill(path, with: .color(fillColor))
                            context.stroke(path, with: .color(.black), lineWidth: 3)
                        }
                    }
                }
                .offset(y: 200)
                
                if let chord = recorder.detectedChord {
                    VStack {
                        HStack {
                            Text("Chord Detected:").font(.system(size: 25))
                            
                            Text(chord)
                                .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(red: 88/255, green: 217/255, blue: 99/255))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                            Button {
                                guard let voicingPlayed = recorder.voicings, let firstVoicing = voicingPlayed.first else {
                                    print("No Chord Detected")
                                    return
                                }
                                chordPlayer.playChord(fretArray: firstVoicing)
                            } label: {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.black)
                            }
                        }
                        if let notes = recorder.detectedNotes {
                            HStack {
                                Text("Notes Played:").font(.system(size: 25))
                                Text("\(notes.joined(separator: ", "))")
                                    .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(red: 88/255, green: 217/255, blue: 99/255))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black, lineWidth: 3)
                                    )
                                Button {
                                    print(recorder.midiNotes.count)
                                    chordPlayer.playMIDI(midiArray: recorder.midiNotes)
                                } label: {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.black)
                                }
                            }
                        }
                    }
                    .font(.system(size: 28 * xScale))
                    .bold()
                    .offset(x: 0, y: -250 * yScale)
                    .modifier(ShimmerModifier())
                }
            }
            }
            .frame(width: w, height: h)
        }
    }
}

#Preview {
    let recorder = AudioController()
    let pianoController = PianoController(audioController: recorder)
    pianoController.keyArray = [
        Key(position: 1, active: true,  note: "C",  MIDI: 0),
        Key(position: 1, active: false, note: "C#", MIDI: 1),
        Key(position: 2, active: false, note: "D",  MIDI: 2),
        Key(position: 2, active: false, note: "D#", MIDI: 3),
        Key(position: 3, active: true,  note: "E",  MIDI: 4),
        Key(position: 4, active: false, note: "F",  MIDI: 5),
        Key(position: 4, active: false, note: "F#", MIDI: 6),
        Key(position: 5, active: true,  note: "G",  MIDI: 7),
        Key(position: 5, active: false, note: "G#", MIDI: 8),
        Key(position: 6, active: false, note: "A",  MIDI: 9),
        Key(position: 6, active: false, note: "A#", MIDI: 10),
        Key(position: 7, active: false, note: "B",  MIDI: 11),
    ]
    return PianoView(recorder: recorder, keys: pianoController, chordPlayer: ChordPlayer())
}
