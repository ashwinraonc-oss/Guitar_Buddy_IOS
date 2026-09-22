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
        VStack{
            BarVisualizer(values: rec.meterHistory, barCount: 24)
                .frame(height: 60)
                .padding(.horizontal)
            
            ProgressView(value: rec.meterLevel)
                .progressViewStyle(.linear)
                .animation(.linear, value: rec.meterLevel)
                .tint(.orange)
            
            HStack{
                Button(rec.isRecording ? "Stop" : "Record"){
                    if rec.isRecording{
                        rec.stop()
                    } else {
                        player.stop()
                        rec.start()
                    }
                }
                Button("Play"){
                    player.play(rec.fileURL)
                }
                .disabled(rec.isRecording || rec.fileURL == nil)
                
            }
            
            if let url = rec.fileURL{
                Text("File: \(url.lastPathComponent)")
                    .font(.footnote)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            List{
                Section("Recordings"){
                    ForEach(recordings, id: \.self){url in
                        HStack{
                            Text(url.lastPathComponent)
                                .font(.footnote)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Button{
                                if player.playingURL == url && player.isPlaying{
                                    player.pause()
                                } else {
                                    player.play(url)
                                }
                            } label:{
                                Image(systemName:
                                        (player.playingURL == url && player.isPlaying) ? "pause.fill" : "play.fill")
                            }
                            .buttonStyle(.plain)
                            
                            ProgressView(value: player.playingURL == url ? player.progress: 0)
                                .frame(width: 60)
                        }
                        
                    }
                    .onDelete{ indexSet in
                        for index in indexSet {
                            let url = recordings[index]
                            try? FileManager.default.removeItem(at: url)
                            if player.playingURL == url {
                                player.stop()
                            }
                        }
                        recordings = recordingList()
                    }
                }
            }
        }
        .padding()
        .task{
            recordings = recordingList()
        }
        .onChange(of: rec.isRecording){ isRecording in
            if isRecording{
                player.stop()
            }else{
                recordings = recordingList()
            }
            
        }
    }
    func recordingList() -> [URL]{
        let dir = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Recording", isDirectory: true)
        guard let dir, let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else {return []}
        return files.filter{$0.pathExtension == "wav"}.sorted{$0.lastPathComponent > $1.lastPathComponent}
    }
}

#Preview {
    MiniRecorderView()
}
