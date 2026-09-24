//
//  MiniRecorderView.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/22/26.
//

import SwiftUI
import Combine
import AVFoundation
struct MiniRecorderView: View {
    @StateObject private var rec = MiniRecorder()
    @State private var recordings: [URL] = []
    @StateObject private var player = MiniPlayer()

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let xScale = w / 390
            let yScale = h / 844

            VStack {
                Text("Record")
                    .font(.system(size: 30 * xScale, weight: .bold))
                    .padding(.top, 10 * yScale)
                    .padding(.bottom, 10 * yScale)
                    .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                    .padding(.horizontal, 20 * xScale)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 3)
                    )

                BarVisualizer(values: rec.isRecording ? rec.meterHistory : player.meterHistory, barCount: 24)
                    .frame(height: 70 * yScale)
                    .padding(.horizontal)

                ProgressView(value: rec.meterLevel)
                    .progressViewStyle(.linear)
                    .animation(.linear, value: rec.meterLevel)
                    .tint(.green)

                HStack {
                    Button {
                        if rec.isRecording {
                            rec.stop()
                        } else {
                            player.stop()
                            rec.start()
                        }
                    } label: {
                        Text(rec.isRecording ? "Stop" : "Record")
                            .font(.system(size: 22 * xScale, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16 * xScale)
                            .padding(.vertical, 10 * yScale)
                            .background(Color(red: 235/255, green: 55/255, blue: 34/255))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.black, lineWidth: 3))
                    }
                    Button {
                        player.play(rec.fileURL)
                    } label: {
                        Text("Play")
                            .font(.system(size: 22 * xScale, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 16 * xScale)
                            .padding(.vertical, 10 * yScale)
                            .background(Color(red: 88/255, green: 217/255, blue: 99/255))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.black, lineWidth: 3))
                    }
                    .disabled(rec.isRecording || rec.fileURL == nil)
                }

                if let url = rec.fileURL {
                    Text("File: \(url.lastPathComponent)")
                        .font(.system(size: 16 * xScale, weight: .bold))
                        .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                        .padding(.horizontal, 12 * xScale)
                        .padding(.vertical, 6 * yScale)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.black, lineWidth: 2))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                Text("Recordings")
                    .font(.system(size: 22 * xScale, weight: .bold))
                    .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                    .padding(.top, 10 * yScale)

                ScrollView {
                    VStack(spacing: 10 * yScale) {
                        ForEach(recordings, id: \.self) { url in
                            HStack {
                                Button {
                                    if player.playingURL == url && player.isPlaying {
                                        player.pause()
                                    } else {
                                        player.play(url)
                                    }
                                } label: {
                                    Image(systemName:
                                            (player.playingURL == url && player.isPlaying) ? "pause.fill" : "play.fill")
                                        .foregroundStyle(.black)
                                }
                                .buttonStyle(.plain)

                                Text(url.lastPathComponent)
                                    .font(.system(size: 16 * xScale, weight: .bold))
                                    .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                                    .lineLimit(1)
                                    .truncationMode(.middle)

                                ProgressView(value: player.playingURL == url ? player.progress: 0)
                                    .frame(width: 70 * xScale)

                                Spacer()

                                Button {
                                    try? FileManager.default.removeItem(at: url)
                                    if player.playingURL == url {
                                        player.stop()
                                    }
                                    recordings = recordingList()
                                } label: {
                                    Image(systemName: "trash.fill")
                                        .foregroundStyle(.black)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 12 * xScale)
                            .padding(.vertical, 8 * yScale)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 4 * xScale)
                    .padding(.vertical, 4 * yScale)
                }
            }
            .padding()
            .background(Color(red: 179/255, green: 235/255, blue: 242/255).ignoresSafeArea())
            .task {
                recordings = recordingList()
            }
            .onChange(of: rec.isRecording) { isRecording in
                if isRecording {
                    player.stop()
                } else {
                    recordings = recordingList()
                }

            }
            .frame(width: w, height: h)
        }
    }
    func recordingList() -> [URL] {
        let dir = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Recording", isDirectory: true)
        guard let dir, let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else {return []}
        return files.filter {$0.pathExtension == "wav"}.sorted {$0.lastPathComponent > $1.lastPathComponent}
    }
}

#Preview {
    MiniRecorderView()
}
