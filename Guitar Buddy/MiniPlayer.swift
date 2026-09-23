//
//  MiniPlayer.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/22/26.
//

import SwiftUI
import Combine
import AVFoundation

final class MiniPlayer: ObservableObject {
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var meterLevel: Float = 0
    @Published var meterHistory: [Float] = Array(repeating: 0, count: 80)
    private var player: AVAudioPlayer?
    private var timer: AnyCancellable?
    private var currentURL: URL?

    func play(_ url: URL?) {
        guard let url else {return}
        if isPlaying, currentURL == url {
            pause()
            return
        }
        stop()

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.isMeteringEnabled = true
            currentURL = url

            player?.prepareToPlay()
            player?.play()

            isPlaying = true

            startUpdatingProgress()

        } catch {
            print("Playback failed: \(error)")
            isPlaying = false
        }
    }
    func pause() {
        player?.pause()
        isPlaying = false
        stopUpdatingProgress()
    }
    func stop() {
        player?.stop()
        isPlaying = false
        progress = 0
        stopUpdatingProgress()
        player = nil
        currentURL = nil
        meterLevel = 0
        meterHistory = Array(repeating: 0, count: 80)
    }
    private func startUpdatingProgress() {
        stopUpdatingProgress()

        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink {
                [weak self] _ in
                guard let self, let player = self.player else {return}
                if player.isPlaying {
                    player.updateMeters()
                    let power = player.averagePower(forChannel: 0)
                    let level = Self.normalize(power)
                    self.meterLevel = level
                    self.meterHistory.append(level)
                    if self.meterHistory.count > 80 {
                        self.meterHistory.removeFirst(self.meterHistory.count - 80)
                    }
                    self.progress = player.duration > 0 ? player.currentTime / player.duration : 0
                } else {
                    self.stop()
                    
                }
            }
    }
    private func stopUpdatingProgress() {
        timer?.cancel()
        timer = nil
    }
    private static func normalize(_ db: Float) -> Float {
        let floor: Float = -40
        if db <= floor {return 0}
        let clamped = max(min(db, 0), floor)
        let linear = (clamped - floor) / -floor
        return linear * linear
        
    }
    func seek(to prog: Double) {
        guard let player, player.duration > 0 else {return}
        player.currentTime = prog * player.duration
        progress = prog
    }

    var isPaused: Bool {
        player != nil && isPlaying && progress > 0 && progress < 1
    }
    var playingURL: URL? { currentURL }
}
