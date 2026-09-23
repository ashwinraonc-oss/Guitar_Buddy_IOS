//
//  Tuner.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/3/26.
//
import AVFoundation
import SwiftUI
import Accelerate
import Combine

struct Tuning {
    let name: String
    let stringMIDI: [Int]
    var stringNames: [String] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        return stringMIDI.map {notes[(($0%12) + 12)%12]}
    }
}
// Tunings
let standardTuning = Tuning(name: "Standard", stringMIDI: [40, 45, 50, 55, 59, 64])       // E A D G B E
let dropDTuning  = Tuning(name: "Drop D", stringMIDI: [38, 45, 50, 55, 59, 64])       // D A D G B E
let dadgadTuning = Tuning(name: "DADGAD", stringMIDI: [38, 45, 50, 55, 57, 62])       // D A D G A D
let dadfceTuning = Tuning(name: "DADFCE", stringMIDI: [38, 45, 50, 53, 60, 64])       // D A D F C E
let dropHalfStepTuning = Tuning(name: "Eb", stringMIDI: [39, 44, 49, 54, 58, 63])// Eb Ab Db Gb Bb Eb
let openGTuning = Tuning(name: "Open G", stringMIDI: [38, 43, 50, 55, 59, 62]) // D G D G B D

class TunerController: NSObject, ObservableObject {
    private var engine = AVAudioEngine()
    nonisolated(unsafe) private var rollingBuffer: [Float] = []
    @Published var detectedNote: String = "--"
    @Published var tuningDirection: String = "--"
    @Published var inTune: Bool = false
    @Published var detectedFrequency: Float = 0
    @Published var isRunning = false
    @Published var centsOff = Float(0)
    @Published var selectedTuning: Tuning = standardTuning
    @Published var closestString: Int?
    private var consecutiveCount = 0
    private var pendingNote = "--"

    func startTuning() {
        let inputNode = engine.inputNode
        let format = inputNode.inputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) {buffer, _ in
            self.processBuffer(buffer)
        }
        do {
            try engine.start()
            DispatchQueue.main.async {
                self.isRunning = true
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    func stopTuning() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        DispatchQueue.main.async {
            self.isRunning = false
        }
    }
    nonisolated private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let frameLength = Int(buffer.frameLength)
        let samples = Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))

        let rms = sqrt(samples.map { $0 * $0 }.reduce(0, +) / Float(frameLength))
        guard rms > 0.003 else {
            DispatchQueue.main.async {
                self.detectedNote = "--"
                self.centsOff = 0
                self.tuningDirection = "--"
                self.closestString = nil
            }
            return
        }

        rollingBuffer.append(contentsOf: samples)
        if rollingBuffer.count > 4096 {
            rollingBuffer.removeFirst(rollingBuffer.count - 4096)
        }
        guard rollingBuffer.count == 4096 else { return }

        let sampleRate = Float(buffer.format.sampleRate)
        let frequency = yin(rollingBuffer, sampleRate: sampleRate)

        guard frequency > 0 else { return }

        let note = frequencyToNote(frequency)
        let centsOff = frequencyToCents(frequency)
        let targetFrequencies = selectedTuning.stringMIDI.map {440 * pow(2, (Float($0) - 69) / 12)}
        let centsDiff = targetFrequencies.map {1200 * log2(frequency / $0)}
        let closestIndex = centsDiff.indices.min(by: { abs(centsDiff[$0]) < abs(centsDiff[$1]) })!
        let diffToClosest = centsDiff[closestIndex]
        let direction: String
        if abs(diffToClosest) < 5 {
            direction = "In Tune!"
        } else if diffToClosest > 0 {
            direction = "Tune Down"
        } else {
            direction = "Tune Up"
        }
        DispatchQueue.main.async {
            if note == self.pendingNote {
                self.consecutiveCount += 1
            } else {
                self.pendingNote = note
                self.consecutiveCount = 1
            }
            if self.consecutiveCount >= 2 {
                if self.detectedNote != note {
                    self.centsOff = 0
                }
                self.detectedNote = note
                self.detectedFrequency = frequency
            }
            self.closestString = closestIndex
            self.tuningDirection = direction
            self.inTune = (direction == "In Tune!")
            self.centsOff = self.centsOff * 0.5 + centsDiff[closestIndex] * 0.5
        }
    }

    nonisolated private func yin(_ samples: [Float], sampleRate: Float) -> Float {
        let bufferSize = samples.count
        let minTau = Int(sampleRate / 1000)  // highest detectable frequency ~1000 Hz
        let maxTau = Int(sampleRate / 50)    // lowest detectable frequency ~50 Hz
        guard maxTau < bufferSize / 2 else { return -1 }

        let windowSize = bufferSize - maxTau
        var yinBuffer = [Float](repeating: 0, count: maxTau + 1)

        // Step 1: difference function using vDSP for SIMD speed
        var diff = [Float](repeating: 0, count: windowSize)
        samples.withUnsafeBufferPointer { ptr in
            let base = ptr.baseAddress!
            for tau in 1...maxTau {
                vDSP_vsub(base + tau, 1, base, 1, &diff, 1, vDSP_Length(windowSize))
                var sumSq: Float = 0
                vDSP_svesq(diff, 1, &sumSq, vDSP_Length(windowSize))
                yinBuffer[tau] = sumSq
            }
        }

        // Step 2: cumulative mean normalized difference
        yinBuffer[0] = 1.0
        var runningSum: Float = 0
        for tau in 1...maxTau {
            runningSum += yinBuffer[tau]
            if runningSum > 0 {
                yinBuffer[tau] = yinBuffer[tau] * Float(tau) / runningSum
            }
        }

        // Step 3: find first dip below threshold
        let threshold: Float = 0.12
        var tau = minTau
        while tau < maxTau - 1 {
            if yinBuffer[tau] < threshold {
                while tau + 1 < maxTau && yinBuffer[tau + 1] < yinBuffer[tau] {
                    tau += 1
                }
                break
            }
            tau += 1
        }
        guard tau < maxTau - 1 else { return -1 }

        // Step 4: parabolic interpolation for sub-sample accuracy
        let s0 = yinBuffer[tau - 1]
        let s1 = yinBuffer[tau]
        let s2 = yinBuffer[tau + 1]
        let denom = 2 * (2 * s1 - s2 - s0)
        let adjustment = denom != 0 ? (s2 - s0) / denom : 0
        let betterTau = Float(tau) + adjustment

        return sampleRate / betterTau
    }

    nonisolated private func frequencyToNote(_ frequency: Float) -> String {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        if frequency < 50 {
            return "--"
        }
        let MIDI = Int(round(12 * log2(frequency / 440)) + 69)
        let note = notes[((MIDI%12)+12)%12]

        return note
    }
    nonisolated private func frequencyToCents(_ frequency: Float) -> Float {
        let exactMIDI = 12 * log2(frequency / 440) + 69
        let nearestMIDI = round(exactMIDI)
        let centsOff = (exactMIDI - nearestMIDI) * 100

        return centsOff
    }

}
