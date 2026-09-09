//
//  ProgressionController.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/7/26.
//

import AVFoundation
import Combine

struct Chord: Hashable {
    let root: String
    let quality: String
    var name: String {
        switch quality {
        case "major":  return root
        case "minor":  return "\(root)m"
        case "dom7":   return "\(root)7"
        case "maj7":   return "\(root)maj7"
        case "min7":   return "\(root)m7"
        case "sus2":   return "\(root)sus2"
        case "sus4":   return "\(root)sus4"
        case "dim":    return "\(root)dim"
        default:       return root
        }
    }
}

struct ChordSuggestion {
    let chord: Chord
    let vibes: Set<String>
    let weight: Int
    let degree: Int
    let keyQuality: String
}

enum Vibe: String, CaseIterable {
    case happy = "Happy"
    case sad = "Sad"
    case melancholy = "Melancholy"
    case intriguing = "Intriguing"
    case romantic = "Romantic"
    case tense = "Tense"
}

struct ProgressionTemplate {
    let degrees: [Int]        // e.g. [1, 5, 6, 4]
    let keyQuality: String    // "major" or "minor"
    let vibes: Set<Vibe>
    let name: String          // e.g. "The Four Chords"
}

let progressionTemplates: [ProgressionTemplate] = [
    // Happy / Upbeat

    ProgressionTemplate(degrees: [1,4,5,1], keyQuality: "major", vibes: [.happy], name: "I-IV-V-I"),
    ProgressionTemplate(degrees: [1,5,4,1], keyQuality: "major", vibes: [.happy], name: "I-V-IV-I"),
    ProgressionTemplate(degrees: [1,2,4,1], keyQuality: "major", vibes: [.happy], name: "I-II-IV-I"),
    ProgressionTemplate(degrees: [1,4,1,5], keyQuality: "major", vibes: [.happy], name: "I-IV-I-V"),
    ProgressionTemplate(degrees: [1,5,6,4], keyQuality: "major", vibes: [.happy], name: "The Four Chords"),

    // Melancholy / Bittersweet

    ProgressionTemplate(degrees: [1,6,4,5], keyQuality: "major", vibes: [.melancholy], name: "50s Progression"),
    ProgressionTemplate(degrees: [1,6,2,5], keyQuality: "major", vibes: [.melancholy], name: "I-vi-ii-V"),
    ProgressionTemplate(degrees: [1,3,4,5], keyQuality: "major", vibes: [.melancholy], name: "I-iii-IV-V"),
    ProgressionTemplate(degrees: [6,4,1,5], keyQuality: "major", vibes: [.melancholy], name: "vi-IV-I-V"),


    // Sad

    ProgressionTemplate(degrees: [1,7,6,7], keyQuality: "minor", vibes: [.sad], name: "i-VII-VI-VII"),
    ProgressionTemplate(degrees: [1,4,5,1], keyQuality: "minor", vibes: [.sad], name: "Minor i-iv-v"),
    ProgressionTemplate(degrees: [1,6,3,7], keyQuality: "minor", vibes: [.sad], name: "i-VI-III-VII"),
    ProgressionTemplate(degrees: [1,4,1,5], keyQuality: "minor", vibes: [.sad], name: "Minor i-iv-i-v"),

    // Intriguing / Tense

    ProgressionTemplate(degrees: [1,7,6,5], keyQuality: "minor", vibes: [.intriguing], name: "Andalusian Cadence"),
    ProgressionTemplate(degrees: [1,7,6,5], keyQuality: "major", vibes: [.intriguing], name: "Descending"),
    ProgressionTemplate(degrees: [2,5,1],   keyQuality: "major", vibes: [.intriguing], name: "ii-V-I"),
    ProgressionTemplate(degrees: [1,5,6,4], keyQuality: "minor", vibes: [.intriguing], name: "Minor i-V-VI-IV"),

    // Romantic

    ProgressionTemplate(degrees: [1,5,6,3,4], keyQuality: "major", vibes: [.romantic], name: "I-V-vi-iii-IV"),
    ProgressionTemplate(degrees: [1,6,4,5],   keyQuality: "major", vibes: [.romantic], name: "I-vi-IV-V"),
    ProgressionTemplate(degrees: [6,2,5,1],   keyQuality: "major", vibes: [.romantic], name: "vi-ii-V-I"),
    ProgressionTemplate(degrees: [1,7,6,5],   keyQuality: "minor", vibes: [.romantic], name: "i-VII-VI-V"),
]

let majorIntervals = [0,2,4,5,7,9,11]
let majorQualities = ["major","minor","minor","major","major","minor","dim"]

let minorIntervals = [0,2,3,5,7,8,10]
let minorQualities = ["minor","dim","major","minor","minor","major","major"]

let notes = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
let scaleTypes = ["major","minor"]




class ProgressionController: NSObject, ObservableObject{
    @Published var suggestions: [ChordSuggestion] = []
    @Published var progression: [Chord] = []
    private var lookupTable: [String: [(keyRoot: String, keyQuality: String, degree: Int)]] = [:]
    
    override init() {
        super.init()
        buildLookUpTable()
    }
    
    private func buildLookUpTable() { //building table to lookup up which chords exist in which contexts
        for note in notes{
            let i = notes.firstIndex(of: note)!
            
            for scale in scaleTypes{
                if scale == "major"{
                    for (degree, interval) in majorIntervals.enumerated(){
                        let chord = Chord(
                            root: notes[(i + interval)%12],
                            quality: majorQualities[degree]
                        )
                        lookupTable[chord.name, default: []].append((keyRoot: note, keyQuality: scale, degree: degree))
                        
                    }
                }
                if scale == "minor"{
                    for (degree, interval) in minorIntervals.enumerated(){
                        let chord = Chord(
                            root: notes[(i + interval)%12],
                            quality: minorQualities[degree]
                        )
                        lookupTable[chord.name, default: []].append((keyRoot: note, keyQuality: scale, degree: degree))
                        
                    }
                    
                }
            }
        }
    }
    func generateProgression(chord: String) {//generates chords that fit with the input chord and sort it by how well those chords fit with the input chord
        let keyContexts = lookupTable[chord]
        var chordWeights: [Chord: Int] = [:]
        for (keyRoot, keyQuality, _) in keyContexts ?? [] { //assigning weight values to chords in the context of the input chord
            let i = notes.firstIndex(of: keyRoot)!
            if keyQuality == "major"{
                for (degree, interval) in majorIntervals.enumerated(){
                    let suggestedChord = Chord(root: notes[(i + interval)%12], quality: majorQualities[degree])
                    if suggestedChord.name != chord {
                        chordWeights[suggestedChord, default: 0] += 1
                    }
                }
            }
            if keyQuality == "minor"{
                for (degree, interval) in minorIntervals.enumerated() {
                    let suggestedChord = Chord(root: notes[(i + interval)%12], quality: minorQualities[degree])
                    if suggestedChord.name != chord {
                        chordWeights[suggestedChord, default: 0] += 1
                    }

                }
                
            }
            
        }
        suggestions = []
        for chordWeight in chordWeights.sorted(by: {$0.value > $1.value}){
            suggestions.append(ChordSuggestion(chord: chordWeight.key, vibes: [], weight: chordWeight.value))
        }
        print(suggestions.map { "\($0.chord.name) (weight: \($0.weight))" })
    }
    func selectChord(_ chord: Chord){
        progression.append(chord)
        generateProgression(chord: chord.name)
    }
    func reset(){
        progression = []
        suggestions = []
    }
    func baseQuality(_ quality: String) -> String {
        switch quality {
        case "maj7", "dom7": return "major"
        case "min7": return "minor"
        default: return quality
        }
    }
}


//  (keyRoot: "C", keyQuality: "major", degree: 6),
//  (keyRoot: "G", keyQuality: "major", degree: 2),
//  (keyRoot: "A", keyQuality: "minor", degree: 1),
//  (keyRoot: "E", keyQuality: "minor", degree: 4),


