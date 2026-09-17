//
//  ProgressionController.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/7/26.
//

import AVFoundation
import Combine
import UIKit

struct VoicingLookup: Codable {//return struct from chord lookup function
    let voicings: [[Int]]
}

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

struct ProgressionTemplate: Hashable {
    let id = UUID()
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

struct ProgressionResult{
    let chords: [Chord]
    let templateName: String
    let vibes: Set<Vibe>
}

let majorIntervals = [0,2,4,5,7,9,11]
let majorQualities = ["major","minor","minor","major","major","minor","dim"]
let major7Qualities = ["maj7", "min7", "min7", "maj7", "dom7", "min7", "dim"]

let minorIntervals = [0,2,3,5,7,8,10]
let minorQualities = ["minor","dim","major","minor","minor","major","major"]
let minor7Qualities = ["min7", "dim",  "maj7", "min7", "min7", "maj7", "dom7"]

let notes = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
let notes_backend = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
let scaleTypes = ["major","minor"]

class ProgressionController: NSObject, ObservableObject{
    @Published var chordVoicings: [String: [[Int]]] = [:]
    @Published var suggestions: [ChordSuggestion] = []
    @Published var progression: [Chord] = []
    @Published var suggestedProgressions: [ProgressionResult] = []
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
                        let seventhChord = Chord(
                            root: notes[(i + interval)%12],
                            quality: major7Qualities[degree]
                        )
                        lookupTable[seventhChord.name, default: []].append((keyRoot: note, keyQuality: scale, degree: degree))
                        
                    }
                }
                if scale == "minor"{
                    for (degree, interval) in minorIntervals.enumerated(){
                        let chord = Chord(
                            root: notes[(i + interval)%12],
                            quality: minorQualities[degree]
                        )
                        lookupTable[chord.name, default: []].append((keyRoot: note, keyQuality: scale, degree: degree))
                        let seventhChord = Chord(
                            root: notes[(i + interval)%12],
                            quality: minor7Qualities[degree]
                        )
                        lookupTable[seventhChord.name, default: []].append((keyRoot: note, keyQuality: scale, degree: degree))
                        
                    }
                    
                }
            }
        }
    }
    func generateProgression(chord: String) {//generates list of chords that fit with the input chord and determines each one's frequency
        let keyContexts = lookupTable[chord]
        var chordWeights: [Chord: Int] = [:]
        var chordContext: [Chord: (degree: Int, keyQuality: String)] = [:]
        for (keyRoot, keyQuality, _) in keyContexts ?? [] { //assigning weight values to chords in the context of the input chord
            let i = notes.firstIndex(of: keyRoot)!
            if keyQuality == "major"{
                for (degree, interval) in majorIntervals.enumerated(){
                    let suggestedChord = Chord(root: notes[(i + interval)%12], quality: majorQualities[degree])
                    if suggestedChord.name != chord {
                        chordWeights[suggestedChord, default: 0] += 1
                    }
                    if chordContext[suggestedChord] == nil{
                        chordContext[suggestedChord] = (degree: degree, keyQuality: keyQuality)
                    }
                }
            }
            if keyQuality == "minor"{
                for (degree, interval) in minorIntervals.enumerated() {
                    let suggestedChord = Chord(root: notes[(i + interval)%12], quality: minorQualities[degree])
                    if suggestedChord.name != chord {
                        chordWeights[suggestedChord, default: 0] += 1
                    }
                    if chordContext[suggestedChord] == nil{
                        chordContext[suggestedChord] = (degree: degree, keyQuality: keyQuality)
                    }
                    
                }
                
            }
            
            
        }
        suggestions = []
        for chordWeight in chordWeights.sorted(by: {$0.value > $1.value}){//looping through and sorting ChordWeights by frequency, and adding it to suggestion array that is shown to User.
            let context = chordContext[chordWeight.key] ?? (degree: 0, keyQuality: "major")
            suggestions.append(ChordSuggestion(chord: chordWeight.key,
                                               vibes: [],
                                               weight: chordWeight.value,
                                               degree: context.degree,
                                               keyQuality: context.keyQuality))
        }
        
        
    }
    func filterProgressions(chord: String, vibe: Vibe?){
        let allChords = progression.map{ Chord(root: $0.root, quality: baseQuality($0.quality)).name }
        var addedQualityByRoot: [String: String] = [:]
        for c in progression {
            addedQualityByRoot[c.root] = c.quality
        }
        let keyContexts = lookupTable[chord] ?? []
        var result: [ProgressionResult] = []
        for (keyRoot, keyQuality, degree) in keyContexts{
            let matches = progressionTemplates.filter { template in
                guard template.keyQuality == keyQuality && template.degrees.contains(degree + 1) else { return false }
                let templateChords = degreesToChords(root: keyRoot, template: template).map { $0.name }
                return allChords.allSatisfy { templateChords.contains($0) }
            }
            for template in matches{
                let chords = degreesToDisplay(root: keyRoot, template: template, addedQualityByRoot: addedQualityByRoot)
                result.append(ProgressionResult(chords: chords, templateName: template.name, vibes: template.vibes))
            }
        }
        var seen = Set<String>() //dedupe
        result = result.filter { seen.insert($0.chords.map { $0.name }.joined()).inserted }
        
        if let vibe = vibe{
            result = result.filter{$0.vibes.contains(vibe)}
        }
        suggestedProgressions = result
    }
    func degreesToChords(root: String, template: ProgressionTemplate) -> [Chord]{
        let i = notes.firstIndex(of: root)!
        let quality = template.keyQuality
        let intervals = quality == "major" ? majorIntervals : minorIntervals
        let qualities = quality == "major" ? majorQualities : minorQualities
        var chords: [Chord] = []
        for degree in template.degrees{
            let chord = Chord(root: notes[(i + intervals[degree - 1])%12], quality: qualities[degree - 1])
            chords.append(chord)
        }
        return chords
        
    }
    func degreesToSeventhChords(root: String, template: ProgressionTemplate) -> [Chord]{
        let i = notes.firstIndex(of: root)!
        let quality = template.keyQuality
        let intervals = quality == "major" ? majorIntervals : minorIntervals
        let qualities = quality == "major" ? major7Qualities : minor7Qualities
        var chords: [Chord] = []
        for degree in template.degrees{
            let seventhChord = Chord(root: notes[(i + intervals[degree - 1])%12], quality: qualities[degree - 1])
            chords.append(seventhChord)
        }
        return chords
    }
    func degreesToDisplay(root: String, template: ProgressionTemplate, addedQualityByRoot: [String: String]) -> [Chord]{
        let i = notes.firstIndex(of: root)!
        let quality = template.keyQuality
        let intervals = quality == "major" ? majorIntervals : minorIntervals
        let qualities = quality == "major" ? majorQualities : minorQualities
        var chords: [Chord] = []
        for degree in template.degrees{
            let chordRoot = notes[(i + intervals[degree - 1])%12]
            let defaultQuality = qualities[degree - 1]
            var displayQuality = defaultQuality
            if let addedQuality = addedQualityByRoot[chordRoot], baseQuality(addedQuality) == defaultQuality {
                displayQuality = addedQuality
            }
            chords.append(Chord(root: chordRoot, quality: displayQuality))
        }
        return chords
    }
    func reset(){
        progression = []
        suggestions = []
        suggestedProgressions = []
        chordVoicings = [:]
        
    }
    func baseQuality(_ quality: String) -> String {
        switch quality {
        case "maj7", "dom7": return "major"
        case "min7": return "minor"
        default: return quality
        }
    }
    func selectChord(_ chord: Chord){
        progression.append(chord)
        generateProgression(chord: chord.name)
        filterProgressions(chord: chord.name, vibe: nil)
        Task { try? await self.lookupVoicings(chord: chord) }
    }
    func lookupVoicings(chord: Chord) async throws{
        var front_to_back_map = ["maj7": "Maj7", "min7": "m7", "major": "Major", "minor": "Minor"]
        let root_num = notes_backend.firstIndex(of: chord.root)
        let quality = chord.quality
        //constructing URL to send root and quality to backend
        guard var backendURLComponent = URLComponents(string: "https://chord-ghost.onrender.com/lookup") else{return}
        let quality_cap = front_to_back_map[quality]
        backendURLComponent.queryItems = [
            URLQueryItem(name: "root", value: "\(root_num ?? 0)"),
            URLQueryItem(name: "quality", value: quality_cap)
        ]
        let backendURL = backendURLComponent.url!
        print("Fetching: \(backendURL)")
        
        let (data, response) = try await URLSession.shared.data(from: backendURL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{return}
        do{
            let result = try JSONDecoder().decode(VoicingLookup.self, from: data)
            print(result.voicings)
            DispatchQueue.main.async{
                self.chordVoicings[chord.name] = result.voicings
            }
        } catch {
            print("error finding chord diagram")
        }
    }
}


//  (keyRoot: "C", keyQuality: "major", degree: 6),
//  (keyRoot: "G", keyQuality: "major", degree: 2),
//  (keyRoot: "A", keyQuality: "minor", degree: 1),
//  (keyRoot: "E", keyQuality: "minor", degree: 4),


