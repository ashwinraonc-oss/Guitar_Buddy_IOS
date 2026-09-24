//
//  ChordPlayer.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/14/26.
//

import AVFoundation
import AudioToolbox
import Combine
import SwiftUI

class ChordPlayer: ObservableObject {
    private let engine = AVAudioEngine()
    private let sampler = AVAudioUnitSampler()

    init() {
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        sampler.volume = 1.0
        try? engine.start()
        loadSoundFont()
    }

    private func loadSoundFont() {
        guard let url = Bundle.main.url(forResource: "GeneralUser-GS", withExtension: "sf2") else {
            print("Soundfont not found")
            return
        }
        try? sampler.loadSoundBankInstrument(
            at: url,
            program: 24,
            bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
            bankLSB: UInt8(kAUSampler_DefaultBankLSB)
        )
    }
    func playChord(fretArray: [Int]) {
        let openStrings: [UInt8] = [40, 45, 50, 55, 59, 64]
        var playedNotes: [UInt8] = []

        for (i, fret) in fretArray.enumerated() {
            guard fret != -1, i < openStrings.count else { continue }
            let note = openStrings[i] + UInt8(fret)
            playedNotes.append(note)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                self.sampler.startNote(note, withVelocity: 80, onChannel: 0)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            playedNotes.forEach { self.sampler.stopNote($0, onChannel: 0) }
        }
    }
    func playMIDI(midiArray: [Int]) {
        let midiArraySorted = midiArray.sorted()
        var playedNotes: [UInt8] = []
        
        for (i, fret) in midiArraySorted.enumerated() {
            let note = UInt8(fret)
            playedNotes.append(note)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                self.sampler.startNote(note, withVelocity: 80, onChannel: 0)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            playedNotes.forEach { self.sampler.stopNote($0, onChannel: 0) }
        }
    }
    func playMIDIUnsorted(midiArray: [Int]) {
        var playedNotes: [UInt8] = []
        
        for (i, fret) in midiArray.enumerated() {
            let note = UInt8(fret)
            playedNotes.append(note)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.13) {
                self.sampler.startNote(note, withVelocity: 80, onChannel: 0)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            playedNotes.forEach { self.sampler.stopNote($0, onChannel: 0) }
        }
    }
}

