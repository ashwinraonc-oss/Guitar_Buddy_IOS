//
//  RecordingView.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 10/2/26.
//

import SwiftUI
import Combine
import AVFoundation
import SwiftData

struct MiniRecorderView: View {
    @StateObject private var rec = MiniRecorder()
    @StateObject private var player = MiniPlayer()
    @State private var selectedRecording: RecorderModel?
    @State private var deleteTarget: RecorderModel?
    @State private var userInput = ""
    @State private var layerTarget: RecorderModel?
    @StateObject private var layerPlayer = LayerPlayer()
    
    @Query(filter: #Predicate<RecorderModel> { $0.parent == nil })
    private var recordings: [RecorderModel]
    
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let xScale = w / 390
            let yScale = h / 844
            VStack {
                VStack(spacing: 30) {
                    Text("File: \(rec.fileURL?.lastPathComponent ?? "")")
                        .font(.system(size: 16 * xScale, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                        .padding(.horizontal, 12 * xScale)
                        .padding(.vertical, 6 * yScale)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.black, lineWidth: 3))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .opacity(rec.fileURL == nil ? 0 : 0)
                    ZStack {
                        //recordings background
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 255/255, green: 255/255, blue: 242/255))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black, lineWidth: 4)
                            )
                            .frame(width: 370, height: 450)
                            // speaker grille texture — thin horizontal/vertical lines clipped to the card
                            .overlay(
                                Canvas { context, size in
                                    let spacing: CGFloat = 16
                                    var x: CGFloat = spacing
                                    while x < size.width {
                                        var path = Path()
                                        path.move(to: CGPoint(x: x, y: 0))
                                        path.addLine(to: CGPoint(x: x, y: size.height))
                                        context.stroke(path, with: .color(.gray.opacity(0.7)), lineWidth: 0.3)
                                        x += spacing
                                    }
                                    var y: CGFloat = spacing
                                    while y < size.height {
                                        var path = Path()
                                        path.move(to: CGPoint(x: 0, y: y))
                                        path.addLine(to: CGPoint(x: size.width, y: y))
                                        context.stroke(path, with: .color(.gray.opacity(0.7)), lineWidth: 0.3)
                                        y += spacing
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            )
                            .offset(y: -70)
                            .scaleEffect(1.05)

                        ///
                        BarVisualizer(values: rec.isRecording ? rec.meterHistory : player.meterHistory, barCount: 24)
                            .frame(width: 340, height: 50)
                            .offset(y: -270)///
                            .scaleEffect(1.0)
                        ScrollView {
                            VStack(spacing: 2 * yScale) {
                                ForEach(recordings, id: \.fileName) { recording in
                                    if let url = LayerPlayer.fileURL(filename: recording.fileName) {
                                        HStack {
                                            Button {
                                                if let layers = recording.layers, !layers.isEmpty {
                                                    layerPlayer.playStack(recording: recording)
                                                } else {
                                                    if player.playingURL == url && player.isPlaying {
                                                        player.pause()
                                                    } else {
                                                        player.play(url)
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: (player.playingURL == url && player.isPlaying) ? "pause.fill" : "play.fill")
                                                    .foregroundStyle((player.playingURL == url && player.isPlaying) ? .red: .white)
                                                    .font(.system(size: 25 * xScale))
                                                
                                            }
                                            .buttonStyle(.plain)
                                            
                                            Text(url.lastPathComponent)
                                                .font(.system(size: 14 * xScale, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color(.white))
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                            ProgressView(value: player.playingURL == url ? player.progress : 0)
                                                .frame(width: 70 * xScale)
                                            
                                            Spacer()
                                            
                                            Button {
                                                selectedRecording = recording
                                                userInput = recording.displayName
                                            } label: {
                                                Image(systemName: "pencil")
                                                .foregroundStyle(.white)
                                                .font(.system(size: 25 * xScale))
                                            }
                                            .buttonStyle(.plain)
                                            Button {
                                                layerPlayer.stop()
                                                layerTarget = recording
                                                rec.start()
                                            } label: {
                                                Image(systemName: "plus.circle")
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 25 * xScale))
                                            }

                                            Button {
                                                deleteTarget = recording
                                            } label: {
                                                Image(systemName: "trash.fill")
                                                    .foregroundStyle(.red)
                                                    .font(.system(size: 25 * xScale))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        .padding(.horizontal, 10 * xScale)
                                        .padding(.vertical, 13 * yScale)
                                        .background(Color(red: 59/255, green: 59/255, blue: 59/255))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(red: 59/255, green: 59/255, blue: 59/255), lineWidth: 4)
                                        )
                                        .scaleEffect(0.9)

                                        if let layers = recording.layers {
                                            ForEach(layers, id: \.fileName) { layer in
                                                if let layerURL = LayerPlayer.fileURL(filename: layer.fileName) {
                                                    HStack {
                                                        Image(systemName: "arrow.turn.down.right")
                                                            .foregroundStyle(.white.opacity(0.5))
                                                            .font(.system(size: 12 * xScale))

                                                        Button {
                                                            if player.playingURL == layerURL && player.isPlaying {
                                                                player.pause()
                                                            } else {
                                                                player.play(layerURL)
                                                            }
                                                        } label: {
                                                            Image(systemName: (player.playingURL == layerURL && player.isPlaying) ? "pause.fill" : "play.fill")
                                                                .foregroundStyle((player.playingURL == layerURL && player.isPlaying) ? .red : .white)
                                                                .font(.system(size: 20 * xScale))
                                                        }
                                                        .buttonStyle(.plain)

                                                        Text(layer.displayName)
                                                            .font(.system(size: 13 * xScale, weight: .semibold, design: .rounded))
                                                            .foregroundStyle(.white.opacity(0.85))
                                                            .lineLimit(1)
                                                            .truncationMode(.middle)

                                                        ProgressView(value: player.playingURL == layerURL ? player.progress : 0)
                                                            .frame(width: 50 * xScale)

                                                        Spacer()

                                                        Button {
                                                            selectedRecording = layer
                                                            userInput = layer.displayName
                                                        } label: {
                                                            Image(systemName: "pencil")
                                                                .foregroundStyle(.white)
                                                                .font(.system(size: 18 * xScale))
                                                        }
                                                        .buttonStyle(.plain)

                                                        Button {
                                                            deleteTarget = layer
                                                        } label: {
                                                            Image(systemName: "trash.fill")
                                                                .foregroundStyle(.red)
                                                                .font(.system(size: 18 * xScale))
                                                        }
                                                        .buttonStyle(.plain)
                                                    }
                                                    .padding(.leading, 28 * xScale)
                                                    .padding(.horizontal, 10 * xScale)
                                                    .padding(.vertical, 8 * yScale)
                                                    .background(Color(red: 45/255, green: 45/255, blue: 45/255))
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .scaleEffect(0.9)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 4 * xScale)
                            .padding(.vertical, 4 * yScale)
                        }
                        .frame(height: 370)
                        .offset(y: -60)///
                        // control panel
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(red: 255/255, green: 255/255, blue: 242/255))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.black, lineWidth: 4)
                                )
                                .frame(width: 400, height: 100)

                            HStack(alignment: .bottom, spacing: 18) {
                                VStack(spacing: 6) {
                                    Button {
                                        if rec.isRecording {
                                            rec.stop()
                                        } else {
                                            layerPlayer.stop()
                                            player.stop()
                                            rec.start()
                                        }
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(Color(red: 60/255, green: 60/255, blue: 60/255))
                                                .frame(width: 55, height: 55)
                                            Circle()
                                                .fill(rec.isRecording ? Color(red: 235/255, green: 54/255, blue: 60/255) : Color(red: 255/255, green: 44/255, blue: 44/255))
                                                .frame(width: 40, height: 40)
                                            Rectangle()
                                                .fill(Color.white)
                                                .frame(width: 3, height: 12)
                                                .offset(y: -14)
                                        }
                                        .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                    }
                                    Text(rec.isRecording ? "Stop" : "Record")
                                        .font(.system(size: 13 * xScale, weight: .bold, design: .rounded))
                                        .foregroundStyle(.black)
                                }
                                VStack(spacing: 6) {
                                    Button {
                                        player.play(rec.fileURL)
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(Color(red: 60/255, green: 60/255, blue: 60/255))
                                                .frame(width: 55, height: 55)
                                            Circle()
                                                .fill(Color(red: 88/255, green: 217/255, blue: 99/255))
                                                .frame(width: 40, height: 40)
                                            Rectangle()
                                                .fill(Color.white)
                                                .frame(width: 3, height: 12)
                                                .offset(y: -14)
                                        }
                                        .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                    }
                                    .disabled(rec.isRecording || rec.fileURL == nil)
                                    .opacity(rec.isRecording || rec.fileURL == nil ? 0.5 : 1)
                                    Text("Play")
                                        .font(.system(size: 13 * xScale, weight: .bold, design: .rounded))
                                        .foregroundStyle(.black)
                                }
                                // decorative knobs — no action, purely for the amp look
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 60/255, green: 60/255, blue: 60/255))
                                            .frame(width: 55, height: 55)
                                        Circle()
                                            .fill(Color(.orange))
                                            .frame(width: 40, height: 40)
                                        Rectangle()
                                            .fill(Color.white)
                                            .frame(width: 3, height: 12)
                                            .offset(y: -14)
                                    }
                                    .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                    Text("Volume")
                                        .font(.system(size: 13 * xScale, weight: .bold, design: .rounded))
                                        .foregroundStyle(.black)
                                }
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 60/255, green: 60/255, blue: 60/255))
                                            .frame(width: 55, height: 55)
                                        Circle()
                                            .fill(Color(.orange))
                                            .frame(width: 40, height: 40)
                                        Rectangle()
                                            .fill(Color.white)
                                            .frame(width: 3, height: 12)
                                            .offset(y: -14)
                                    }
                                    .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                    Text("Tone")
                                        .font(.system(size: 13 * xScale, weight: .bold, design: .rounded))
                                        .foregroundStyle(.black)
                                }
                                // 1/4" input jack — decorative, no action
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 180/255, green: 180/255, blue: 185/255))
                                            .frame(width: 45, height: 45)
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: 20, height: 20)
                                    }
                                    .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                    Text("Input")
                                        .font(.system(size: 13 * xScale, weight: .bold, design: .rounded))
                                        .foregroundStyle(.black)
                                }
                            }
                            .frame(height: 90)
                        }
                        .offset(y: -395)
                        .scaleEffect(0.97)
                    }
                    .frame(width: 400, height: 570)
                    .offset(y: 90)
                }
                .padding()
                .alert("Rename file", isPresented: Binding(
                    get: { selectedRecording != nil },
                    set: { if !$0 { selectedRecording = nil } }
                )) {
                    TextField("New Filename", text: $userInput)
                    Button("Cancel", role: .cancel) { selectedRecording = nil }
                    Button("OK") {
                        let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed != "" {
                            selectedRecording?.displayName = trimmed
                        }
                        userInput = ""
                        selectedRecording = nil
                    }
                }
                .alert("Delete File?", isPresented: Binding(
                    get: { deleteTarget != nil },
                    set: { if !$0 { deleteTarget = nil } }
                )) {
                    Button("Cancel", role: .cancel) { deleteTarget = nil }
                    Button("OK", role: .destructive) {
                        guard let target = deleteTarget else { return }
                        if let layers = target.layers {
                            for layer in layers {
                                if let layerURL = LayerPlayer.fileURL(filename: layer.fileName) {
                                    try? FileManager.default.removeItem(at: layerURL)
                                    if player.playingURL == layerURL { player.stop() }
                                }
                            }
                        }
                        if let targetURL = LayerPlayer.fileURL(filename: target.fileName) {
                            try? FileManager.default.removeItem(at: targetURL)
                            if player.playingURL == targetURL { player.stop() }
                        }
                        modelContext.delete(target)
                        deleteTarget = nil
                    }
                }
                .onChange(of: rec.isRecording) { isRecording in
                    if isRecording {
                        player.stop()
                    } else {
                        guard let url = rec.fileURL else { return }
                        let newRecording = RecorderModel(
                            fileName: url.lastPathComponent,
                            displayName: url.deletingPathExtension().lastPathComponent,
                            createdDate: .now,
                            parent: layerTarget,
                            layers: []
                        )
                        modelContext.insert(newRecording)
                        layerTarget = nil
                    }
                }
            }
            .frame(width: w, height: h)
            .background(Color(red: 120/255, green: 252/255, blue: 197/255).ignoresSafeArea())
        }
    }
    func recordingList() -> [URL] {
        let dir = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Recording", isDirectory: true)
        guard let dir, let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else { return [] }

        return files.filter { $0.pathExtension == "wav" }
            .sorted { url1, url2 in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? .distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? .distantPast
                return date1 > date2
            }
    }
}

#Preview {
    MiniRecorderView()
}
