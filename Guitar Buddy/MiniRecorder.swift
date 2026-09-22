//
//  MiniRecorder.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/21/26.
//

import Combine
import AVFoundation

final class MiniRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate{
    var recordingSession: AVAudioSession!
    var recorder: AVAudioRecorder?
    @Published var isRecording = false
    @Published var meterLevel: Float = 0
    @Published var meterHistory: [Float] = []
    
    private var meterTimer: AnyCancellable?
    private(set) var fileURL: URL?
    
    func start(){
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            let dir = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("Recording", isDirectory: true)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let stamp = ISO8601DateFormatter().string(from: .now).replacingOccurrences(of: ":", with: "-")
            let url = dir.appendingPathComponent("\(stamp).wav")
            fileURL = url
            
            let audioSettings: [String: Any] = [AVFormatIDKey: kAudioFormatLinearPCM,
                                              AVSampleRateKey: 44100.0,
                                        AVNumberOfChannelsKey: 1,
                                       AVLinearPCMBitDepthKey: 16]
            recorder = try AVAudioRecorder(url: url, settings: audioSettings)
            recorder?.isMeteringEnabled = true
            recorder?.record()
            isRecording = true
            
            startMetering()
        }
        catch{
            print("Start Failed: \(error)")
            
        }
        
    }
    private func startMetering(){
        meterTimer?.cancel()
        meterTimer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink{ [weak self] _ in
                guard let self, let rec = self.recorder, rec.isRecording else {return}
                rec.updateMeters()
                
                let power = rec.averagePower(forChannel: 0)
                self.meterLevel = Self.normalize(power)
                self.meterHistory.append(self.meterLevel)
                
                if self.meterHistory.count > 80{
                    self.meterHistory.removeFirst(self.meterHistory.count - 80)
                }
            }
    }
    private static func normalize(_ db: Float) -> Float {
        let floor: Float = -60
        if db <= floor {return 0}
        let clamped = max(min(db, 0), floor)
        return (clamped - floor) / -floor
    }
    
    private func stopMetering(){
        meterTimer?.cancel()
        meterTimer = nil
        meterLevel = 0
        meterHistory.removeAll()
    }
    func stop(){
        stopMetering()
        recorder?.stop()
        isRecording = false
        recorder = nil
    }
    
}
