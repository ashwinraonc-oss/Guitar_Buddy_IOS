////
////  MiniRecorderView.swift
////  Guitar Buddy
////
////  Created by Ashwin Rao on 9/22/26.
////
//
//import SwiftUI
//import Combine
//import AVFoundation
//
//struct MiniRecorderView: View {
//    @StateObject private var rec = MiniRecorder()
//    @State private var recordings: [URL] = []
//    @StateObject private var player = MiniPlayer()
//    @State private var selectedURL: URL?
//    @State private var showAlert = false
//    @State private var userInput = ""
//
//    var body: some View {
//        GeometryReader { geo in
//            let w = geo.size.width
//            let h = geo.size.height
//            let xScale = w / 390
//            let yScale = h / 844
//            VStack {
//                VStack(spacing: 30) {
//                    Text("Record")
//                        .font(.system(size: 30 * xScale, weight: .bold, design: .rounded))
//                        .padding(.top, 10 * yScale)
//                        .padding(.bottom, 10 * yScale)
//                        .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
//                        .padding(.horizontal, 20 * xScale)
//                        .background(Color.white)
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.black, lineWidth: 3)
//                        )
//
//                    ProgressView(value: rec.meterLevel)
//                        .progressViewStyle(.linear)
//                        .animation(.linear, value: rec.meterLevel)
//                        .tint(.green)
//
//                    Text("File: \(rec.fileURL?.lastPathComponent ?? "")")
//                        .font(.system(size: 16 * xScale, weight: .bold, design: .rounded))
//                        .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
//                        .padding(.horizontal, 12 * xScale)
//                        .padding(.vertical, 6 * yScale)
//                        .background(Color.white)
//                        .clipShape(Capsule())
//                        .overlay(Capsule().stroke(Color.black, lineWidth: 3))
//                        .lineLimit(1)
//                        .truncationMode(.middle)
//                        .opacity(rec.fileURL == nil ? 0 : 0)
//                    ZStack {
//                        ZStack {
//                            //Actual orange amp background
//                            RoundedRectangle(cornerRadius: 20)
//                                .fill(Color(red: 255/255, green: 140/255, blue: 0/255))
////                                .fill(Color(red: 210/255, green: 125/255, blue: 45/255))
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 20)
//                                        .stroke(Color.black, lineWidth: 4)
//                                )
//                                .frame(height: 560)
//                            // corner protectors — outer corner matches the cabinet's curve so they hug it instead of floating near it
//                            VStack {
//                                HStack {
//                                    UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 3, bottomTrailingRadius: 3, topTrailingRadius: 3)
//                                        .stroke(Color.black, lineWidth: 8)
//                                        .fill(Color(.black))
//                                        .frame(width: 35, height: 35)
//                                    
//                                    Spacer()
//                                    UnevenRoundedRectangle(topLeadingRadius: 3, bottomLeadingRadius: 3, bottomTrailingRadius: 3, topTrailingRadius: 18)
//                                        .stroke(Color.black, lineWidth: 8)
//                                        .fill(Color(.black))
//                                        .frame(width: 35, height: 35)
//                                        
//                                }
//                                Spacer()
//                                HStack {
//                                    UnevenRoundedRectangle(topLeadingRadius: 3, bottomLeadingRadius: 18, bottomTrailingRadius: 3, topTrailingRadius: 3)
//                                        .stroke(Color.black, lineWidth: 8)
//                                        .fill(Color(.black))
//                                        .frame(width: 35, height: 35)
//                                    Spacer()
//                                    UnevenRoundedRectangle(topLeadingRadius: 3, bottomLeadingRadius: 3, bottomTrailingRadius: 18, topTrailingRadius: 3)
//                                        .stroke(Color(.black), lineWidth: 8)
//                                        .fill(Color(.black))
//                                        .frame(width: 35, height: 35)
//                                }
//                            }
//                            .padding(-3)
//                        }
//                        .frame(width: 400, height: 420)
//                        .offset(y: -95)
//                        // handle
//                        Ellipse()
//                            .trim(from: 0.5, to: 1.0)
//                            .stroke(Color.black, lineWidth: 7)
//                            .frame(width: 154, height: 40)
//                            .offset(y: -375)
//                        //recordings background
//                        RoundedRectangle(cornerRadius: 16)
//                            .fill(Color(red: 228/255, green: 205/255, blue: 158/255))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 16)
//                                    .stroke(Color.black, lineWidth: 4)
//                            )
//                            .frame(width: 370, height: 320)
//                            .offset(y: -20)
//                        BarVisualizer(values: rec.isRecording ? rec.meterHistory : player.meterHistory, barCount: 24)
//                            .frame(width: 340, height: 40)
//                            .offset(y: -150)
//                        ScrollView {
//                            VStack(spacing: 2 * yScale) {
//                                ForEach(recordings, id: \.self) { url in
//                                    HStack {
//                                        Button {
//                                            if player.playingURL == url && player.isPlaying {
//                                                player.pause()
//                                            } else {
//                                                player.play(url)
//                                            }
//                                        } label: {
//                                            Image(systemName: (player.playingURL == url && player.isPlaying) ? "pause.fill" : "play.fill")
//                                                .foregroundStyle((player.playingURL == url && player.isPlaying) ? .red: .green)
//                                            .font(.system(size: 25 * xScale))
//                                            
//                                        }
//                                        .buttonStyle(.plain)
//
//                                        Text(url.lastPathComponent)
//                                            .font(.system(size: 14 * xScale, weight: .bold, design: .rounded))
//                                            .foregroundStyle(Color(.black))
//                                            .lineLimit(1)
//                                            .truncationMode(.middle)
//                                        ProgressView(value: player.playingURL == url ? player.progress : 0)
//                                            .frame(width: 70 * xScale)
//
//                                        Spacer()
//                                        
//                                        Button {
//                                            selectedURL = url
//                                            showAlert = true
//                                        } label: {
//                                            Image(systemName: "pencil")
//                                                .foregroundStyle(.green)
//                                                .font(.system(size: 25 * xScale))
//                                        }
//                                        .alert("Rename file", isPresented: $showAlert){
//                                            TextField("New Filename", text: $userInput)
//                                            Button("OK") {
//                                                let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
//                                                if trimmed != ""{
//                                                    if player.playingURL == selectedURL {
//                                                        player.stop()
//                                                    }
//                                                    if let selectedURL {
//                                                        rec.renameFile(selectedURL, to: trimmed)
//                                                    }
//                                                    recordings = recordingList()
//                                                    userInput = ""
//                                                }
//                                            }
//                                        }
//                                        .buttonStyle(.plain)
//
//                                        Button {
//                                            try? FileManager.default.removeItem(at: url)
//                                            if player.playingURL == url {
//                                                player.stop()
//                                            }
//                                            recordings = recordingList()
//                                        } label: {
//                                            Image(systemName: "trash.fill")
//                                                .foregroundStyle(.red)
//                                                .font(.system(size: 25 * xScale))
//                                        }
//                                        .buttonStyle(.plain)
//                                    }
//                                    .padding(.horizontal, 10 * xScale)
//                                    .padding(.vertical, 13 * yScale)
//                                    .background(Color(.white))
//                                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 12)
//                                            .stroke(Color.black, lineWidth: 4)
//                                    )
//                                    .scaleEffect(0.9)
//                                }
//                            }
//                            .padding(.horizontal, 4 * xScale)
//                            .padding(.vertical, 4 * yScale)
//                        }
//                        .frame(height: 250)
//                        .offset(y: -5)
//                        // control panel
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 14)
//                                .fill(Color(red: 228/255, green: 205/255, blue: 158/255))
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 14)
//                                        .stroke(Color.black, lineWidth: 4)
//                                )
//                                .frame(width: 360, height: 100)
//
//                            HStack(spacing: 26) {
//                                VStack(spacing: 6) {
//                                    Button {
//                                        if rec.isRecording {
//                                            rec.stop()
//                                        } else {
//                                            player.stop()
//                                            rec.start()
//                                        }
//                                    } label: {
//                                        ZStack {
//                                            Circle()
//                                                .fill(Color(red: 60/255, green: 60/255, blue: 60/255))
//                                                .frame(width: 55, height: 55)
//                                            Circle()
//                                                .fill(rec.isRecording ? Color(red: 235/255, green: 54/255, blue: 60/255) : Color(red: 255/255, green: 44/255, blue: 44/255))
//                                                .frame(width: 40, height: 40)
//                                            Rectangle()
//                                                .fill(Color.white)
//                                                .frame(width: 3, height: 12)
//                                                .offset(y: -14)
//                                        }
//                                        .overlay(Circle().stroke(Color.black, lineWidth: 3))
//                                    }
//                                    Text(rec.isRecording ? "Stop" : "Record")
//                                        .font(.system(size: 13 * xScale, weight: .regular, design: .rounded))
//                                        .foregroundStyle(.black)
//                                }
//                                VStack(spacing: 6) {
//                                    Button {
//                                        player.play(rec.fileURL)
//                                    } label: {
//                                        ZStack {
//                                            Circle()
//                                                .fill(Color(red: 60/255, green: 60/255, blue: 60/255))
//                                                .frame(width: 55, height: 55)
//                                            Circle()
//                                                .fill(Color(red: 88/255, green: 217/255, blue: 99/255))
//                                                .frame(width: 40, height: 40)
//                                            Rectangle()
//                                                .fill(Color.white)
//                                                .frame(width: 3, height: 12)
//                                                .offset(y: -14)
//                                        }
//                                        .overlay(Circle().stroke(Color.black, lineWidth: 3))
//                                    }
//                                    .disabled(rec.isRecording || rec.fileURL == nil)
//                                    .opacity(rec.isRecording || rec.fileURL == nil ? 0.5 : 1)
//                                    Text("Play")
//                                        .font(.system(size: 13 * xScale, weight: .regular, design: .rounded))
//                                        .foregroundStyle(.black)
//                                }
//                                // decorative knobs — no action, purely for the amp look
//                                VStack(spacing: 6) {
//                                    ZStack {
//                                        Circle()
//                                            .fill(Color(red: 60/255, green: 60/255, blue: 60/255))
//                                            .frame(width: 55, height: 55)
//                                        Circle()
//                                            .fill(Color(.orange))
//                                            .frame(width: 40, height: 40)
//                                        Rectangle()
//                                            .fill(Color.white)
//                                            .frame(width: 3, height: 12)
//                                            .offset(y: -14)
//                                    }
//                                    .overlay(Circle().stroke(Color.black, lineWidth: 3))
//                                    Text("Volume")
//                                        .font(.system(size: 13 * xScale, weight: .regular, design: .rounded))
//                                        .foregroundStyle(.black)
//                                }
//                                VStack(spacing: 6) {
//                                    ZStack {
//                                        Circle()
//                                            .fill(Color(red: 60/255, green: 60/255, blue: 60/255))
//                                            .frame(width: 55, height: 55)
//                                        Circle()
//                                            .fill(Color(.orange))
//                                            .frame(width: 40, height: 40)
//                                        Rectangle()
//                                            .fill(Color.white)
//                                            .frame(width: 3, height: 12)
//                                            .offset(y: -14)
//                                    }
//                                    .overlay(Circle().stroke(Color.black, lineWidth: 3))
//                                    Text("Tone")
//                                        .font(.system(size: 13 * xScale, weight: .regular, design: .rounded))
//                                        .foregroundStyle(.black)
//                                }
//                            }
//                            .frame(height: 90)
//                        }
//                        .offset(y: -258)
//                    }
//                    .frame(width: 400, height: 570)
//                    .offset(y: 50)
//                }
//                .padding()
//                .task {
//                    recordings = recordingList()
//                }
//                .onChange(of: rec.isRecording) { isRecording in
//                    if isRecording {
//                        player.stop()
//                    } else {
//                        recordings = recordingList()
//                    }
//                }
//            }
//            .frame(width: w, height: h)
//            .background(Color(red: 179/255, green: 235/255, blue: 242/255).ignoresSafeArea())
//        }
//    }
//    func recordingList() -> [URL] {
//        let dir = try? FileManager.default
//            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//            .appendingPathComponent("Recording", isDirectory: true)
//        guard let dir, let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else { return [] }
//        return files.filter { $0.pathExtension == "wav" }.sorted { $0.lastPathComponent > $1.lastPathComponent }
//    }
//}
//
//#Preview {
//    MiniRecorderView()
//}
