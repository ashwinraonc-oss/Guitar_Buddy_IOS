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
    private let samplerPiano = AVAudioUnitSampler()
    private var dispatchItems: [DispatchWorkItem] = []
    private var currentlyPlaying: [(note: UInt8, sampler: AVAudioUnitSampler)] = []
    private var lastPlayTime: Date = .distantPast
    private let minPlayInterval: TimeInterval = 0.15

    init() {
        engine.attach(sampler)//guitar sampler
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        engine.attach(samplerPiano)//piano sampler
        engine.connect(samplerPiano, to: engine.mainMixerNode, format: nil)
        sampler.volume = 1.0
        samplerPiano.volume = 1.0
        try? engine.start()
        loadSoundFont()
        loadPianoSoundFont()
    }
    //load GS sound file for guitar playback
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
    //load GS sound file for piano playback
    private func loadPianoSoundFont() {
        guard let url = Bundle.main.url(forResource: "GeneralUser-GS", withExtension: "sf2") else {
            print("Soundfont not found")
            return
        }
        try? samplerPiano.loadSoundBankInstrument(
            at: url,
            program: 2,
            bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
            bankLSB: UInt8(kAUSampler_DefaultBankLSB)
        )
    }
    //play guitar midi notes given a guitar voicing
    func playChord(fretArray: [Int]) {
        let now = Date()
        guard now.timeIntervalSince(lastPlayTime) > minPlayInterval else { return }
        lastPlayTime = now

        if !engine.isRunning {
            try? engine.start()
        }
        //cancel all other sounds
        for item in dispatchItems{
            item.cancel()
        }
        sampler.sendController(120, withValue: 0, onChannel: 0)
        samplerPiano.sendController(120, withValue: 0, onChannel: 0)
        dispatchItems.removeAll()
        currentlyPlaying.removeAll()
        let openStrings: [UInt8] = [40, 45, 50, 55, 59, 64]
        var playedNotes: [UInt8] = []

        for (i, fret) in fretArray.enumerated() {
            guard fret != -1, i < openStrings.count else { continue }
            let note = openStrings[i] + UInt8(fret)
            playedNotes.append(note)
            currentlyPlaying.append((note, sampler))
            
            let workItem = DispatchWorkItem {[weak self] in
                guard let self = self else {return}
                self.sampler.startNote(note, withVelocity: 80, onChannel: 0)
            }
            dispatchItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1, execute: workItem)
        }

        let workItemEnd = DispatchWorkItem {[weak self] in
            guard let self = self else {return}
            playedNotes.forEach { self.sampler.stopNote($0, onChannel: 0) }
        }
        dispatchItems.append(workItemEnd)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: workItemEnd)
    }
    //play guitar midi notes given array of midi notes that are sorted
    func playMIDI(midiArray: [Int]) {
        let now = Date()
        guard now.timeIntervalSince(lastPlayTime) > minPlayInterval else { return }
        lastPlayTime = now

        if !engine.isRunning {
            try? engine.start()
        }
        //cancel all other sounds
        for item in dispatchItems{
            item.cancel()
        }
        sampler.sendController(120, withValue: 0, onChannel: 0)
        samplerPiano.sendController(120, withValue: 0, onChannel: 0)
        dispatchItems.removeAll()
        currentlyPlaying.removeAll()
        let midiArraySorted = midiArray.sorted()
        var playedNotes: [UInt8] = []
        
        for (i, fret) in midiArray.enumerated() {
            let note = UInt8(fret)
            playedNotes.append(note)
            currentlyPlaying.append((note, sampler))
            let workItem = DispatchWorkItem {[weak self] in
                guard let self = self else {return}
                self.sampler.startNote(note, withVelocity: 80, onChannel: 0)
            }
            dispatchItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.13, execute: workItem)
        }
        
        let workItemEnd = DispatchWorkItem {[weak self] in
            guard let self = self else {return}
            playedNotes.forEach { self.sampler.stopNote($0, onChannel: 0) }
        }
        dispatchItems.append(workItemEnd)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: workItemEnd)
    }
    //play guitar midi notes given array of midi notes that are unsorted
    func playMIDIUnsorted(midiArray: [Int]) {
        let now = Date()
        guard now.timeIntervalSince(lastPlayTime) > minPlayInterval else { return }
        lastPlayTime = now

        if !engine.isRunning {
            try? engine.start()
        }
        //cancel all other sounds
        for item in dispatchItems{
            item.cancel()
        }
        sampler.sendController(120, withValue: 0, onChannel: 0)
        samplerPiano.sendController(120, withValue: 0, onChannel: 0)
        dispatchItems.removeAll()
        currentlyPlaying.removeAll()
        var playedNotes: [UInt8] = []
        
        for (i, fret) in midiArray.enumerated() {
            let note = UInt8(fret)
            playedNotes.append(note)
            currentlyPlaying.append((note, sampler))
            let workItem = DispatchWorkItem {[weak self] in
                guard let self = self else {return}
                self.sampler.startNote(note, withVelocity: 80, onChannel: 0)
            }
            dispatchItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.13, execute: workItem)
        }
        
        let workItemEnd = DispatchWorkItem {[weak self] in
            guard let self = self else {return}
            playedNotes.forEach { self.sampler.stopNote($0, onChannel: 0) }
        }
        dispatchItems.append(workItemEnd)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: workItemEnd)
    }
    //play piano midi notes given array of midi notes that are sorted
    func playPianoChord(midiArray: [Int]) {
        let now = Date()
        guard now.timeIntervalSince(lastPlayTime) > minPlayInterval else { return }
        lastPlayTime = now

        if !engine.isRunning {
            try? engine.start()
        }
        //cancel all other sounds
        for item in dispatchItems{
            item.cancel()
        }
        sampler.sendController(120, withValue: 0, onChannel: 0)
        samplerPiano.sendController(120, withValue: 0, onChannel: 0)
        dispatchItems.removeAll()
        currentlyPlaying.removeAll()
        var playedNotes: [UInt8] = []
        
        for (i, fret) in midiArray.enumerated() {
            let note = UInt8(fret)
            playedNotes.append(note)
            currentlyPlaying.append((note, samplerPiano))
            let workItem = DispatchWorkItem {[weak self] in
                guard let self = self else {return}
                self.samplerPiano.startNote(note, withVelocity: 80, onChannel: 0)
            }
            dispatchItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.13, execute: workItem)
        }
        
        let workItemEnd = DispatchWorkItem {[weak self] in
            guard let self = self else {return}
            playedNotes.forEach { self.samplerPiano.stopNote($0, onChannel: 0) }
        }
        dispatchItems.append(workItemEnd)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: workItemEnd)
    }

}
