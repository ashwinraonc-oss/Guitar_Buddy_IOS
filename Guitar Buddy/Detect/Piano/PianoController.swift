//
//  PianoController.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/24/26.
//

import SwiftUI
import AVFoundation
import Combine

let MIDI_Sharps: [Int] = [1,3,6,8,10]
let base_MIDIs: [Int] = [0,1,2,3,4,5,6,7,8,9,10,11]

//let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

struct Key {
    let position: Int
    var active: Bool = false
    let note: String
    let MIDI: Int
    var type: String {
        switch MIDI%12 {
        case let value where MIDI_Sharps.contains(MIDI % 12):  return "Black"
        default:  return "White"
        }
    }
}

class PianoController: NSObject, ObservableObject{
    @Published var keyArray: [Key] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(audioController: AudioController) {
        super.init()
        audioController.$chord_notes_names_midi
            .sink { [weak self] midis in
                self?.generateKeyArray(noteArray: audioController.chord_notes_names, midiArray: midis)
            }
            .store(in: &cancellables)
    }
    
    
    
    func generateKeyArray(noteArray: [String], midiArray: [Int]){
        print(noteArray, midiArray)
        var whiteCount = 0
        var count = 0
        for i in 0..<12{
            if noteArray.contains(notes_backend[i]){//piano key is detected and should be active on piano
                let notePos = noteArray.firstIndex(of: notes_backend[i])!
                if !MIDI_Sharps.contains(midiArray[notePos] % 12){
                    whiteCount += 1
                    count = whiteCount
                } else {
                    count = whiteCount
                }
                let newKey = Key(position: count, active: true, note: notes_backend[i], MIDI: midiArray[notePos])
                keyArray.append(newKey)
            } else {//piano key is not detected and should not be active on piano
                if !MIDI_Sharps.contains(base_MIDIs[i] % 12){//is a white key
                    whiteCount += 1
                    count = whiteCount
                } else { // is a black key
                    count = whiteCount
                }
                let newKey = Key(position: count, active: false, note: notes_backend[i], MIDI: base_MIDIs[i])
                keyArray.append(newKey)
            }
        }
    }
}




