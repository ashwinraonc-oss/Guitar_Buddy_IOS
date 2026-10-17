//
//  RecorderModelController.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 10/3/26.
//

import Combine
import AVFoundation
import SwiftData

class LayerPlayer: ObservableObject {
    private let engine = AVAudioEngine()
    private var activeNodes: [AVAudioPlayerNode] = []
    
    init(){
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
            try session.setActive(true)
            _ = engine.mainMixerNode
            try engine.start()
        } catch {
            print("Session setup failed: \(error)")
        }
    }

    func playStack(recording: RecorderModel){
        stopNodes(nodes: activeNodes)
        var recordingList: [RecorderModel] = [recording]
        if let layers = recording.layers {
            for rec in layers {
                recordingList.append(rec)
            }
        }
        buildNodes(recordings: recordingList)

        guard let lastRenderTime = engine.outputNode.lastRenderTime else { return }
        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        let startSampleTime = lastRenderTime.sampleTime + AVAudioFramePosition(sampleRate * 0.1)
        let startTime = AVAudioTime(sampleTime: startSampleTime, atRate: sampleRate)
        
        for node in activeNodes{
            node.play(at: startTime)
        }
    }
    
    func buildNodes(recordings: [RecorderModel]){
        let format = engine.outputNode.outputFormat(forBus: 0)
        guard format.sampleRate > 0 else { return }
        for recording in recordings{
            guard let recordingURL = Self.fileURL(filename: recording.fileName) else { continue }
            let newNode = AVAudioPlayerNode()
            guard let audioFile = try? AVAudioFile(forReading: recordingURL) else { continue }

            engine.attach(newNode)
            engine.connect(newNode, to: engine.mainMixerNode, format: audioFile.processingFormat)
            newNode.scheduleFile(audioFile, at: nil)
            activeNodes.append(newNode)
        }
    }
    
    static func fileURL(filename: String) -> URL? {
        guard let dir = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Recording", isDirectory: true)
        else { return nil }
        return dir.appendingPathComponent(filename)
    }
    
    func stopNodes(nodes: [AVAudioPlayerNode]){
        for node in nodes{
            node.stop()
            engine.detach(node)
        }
        activeNodes.removeAll()
    }
    
    func stop() {
        stopNodes(nodes: activeNodes)
    }
}



