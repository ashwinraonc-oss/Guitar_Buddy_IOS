//
//  ContentView.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 8/31/26.
//

import SwiftUI
import AVFoundation
import Lottie



struct ContentView: View {
    @ObservedObject var recorder: AudioController
    @State private var voicingIndex: Int = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let xScale = w / 390
            let yScale = h / 844
            

            ZStack {
                // 1. Yellow background (bottom)
                Color(red: 210/255, green: 125/255, blue: 45/255)
                    .ignoresSafeArea()
                VStack {
                    Text("Chord Detector")
                        .font(.system(size: 40 * xScale))
                        .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                        .bold()
                        .offset(y: 5500 * yScale)
                        .background(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 92/255, green: 67/255, blue: 33/255))
                                .frame(width: 130 * xScale, height: 400 * yScale)
                                .offset(x: 0, y: 255 * yScale)
                            // Fret lines
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 378 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 328 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 278 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 228 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 178 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 128 * yScale)
//                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 250 * yScale)
//                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 220 * yScale)
//                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 190 * yScale)
//                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 160 * yScale)
//                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 130 * yScale)
                        }

                    if let chord = recorder.detectedChord {
                        VStack {
                            Text("Chord Detected:")
                            Text(chord)
                                .foregroundStyle(Color(red: 101/255, green: 67/255, blue: 33/255))
                            if let notes = recorder.detectedNotes {
                                HStack{
                                    Text("Notes:")
                                    Text(notes.joined(separator: ", "))
                                        .foregroundStyle(Color(red: 101/255, green: 67/255, blue: 33/255))
                                }
                            }
                        }
                        .font(.system(size: 33 * xScale))
                        .bold()
                        .offset(y: 570 * yScale)
                    }
                    if recorder.failedConnection == true {
                        Text("Connection Failed")
                            .font(.system(size: 30 * xScale))
                            .foregroundStyle(.red)
                            .bold()
                            .offset(y: 550 * yScale)
                    }
                    if recorder.isDetecting == true {
//                        ProgressView()
//                            .progressViewStyle(.circular)
//                            .scaleEffect(2)
//                            .tint(.black)
//                            .offset(y: 550 * yScale)
                        LottieView(animation:
                                .named("loading"))
                                .playing()
                                .looping()
                                .resizable()
                                .frame(width: 130 * xScale, height: 130 * xScale)
                                .offset(x: 0, y: 540 * yScale)
                    }

                    Spacer()
                    Button {
                        if recorder.isRecording {
                            recorder.stopRecording()
                        } else {
                            recorder.startRecording()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 70 * xScale, height: 70 * xScale)
                            Circle()
                                .stroke(Color.black, lineWidth: 10)
                                .frame(width: 73 * xScale, height: 73 * xScale)
                            Circle()
                                .stroke(Color(red: 210/255, green: 125/255, blue: 45/255), lineWidth: 4)
                                .frame(width: 76 * xScale, height: 76 * xScale)
                            RoundedRectangle(cornerRadius: recorder.isRecording ? 8 : 40)
                                .fill(Color(red: 235/255, green: 55/255, blue: 34/255))
                                .frame(
                                    width: recorder.isRecording ? 30 * xScale : 70 * xScale,
                                    height: recorder.isRecording ? 30 * xScale : 70 * xScale
                                )
                                .animation(.easeInOut(duration: 0.3), value: recorder.isRecording)
//                            if recorder.isRecording{
//                                LottieView(animation:
//                                        .named("Ripple Red"))
//                                        .playing()
//                                        .resizable()
//                                        .looping()
//                                        .frame(width: 130 * xScale, height: 130 * xScale)
//                            }
                        }
                    }
                    .scaleEffect(3.0)
                    .offset(x: 0, y: -380 * yScale)
                }
                .frame(maxWidth: .infinity)
                
                if recorder.isRecording{
                    LottieView(animation:
                            .named("Ripple Red"))
                    .playing(.fromProgress(0,toProgress: 1, loopMode: .autoReverse))
                            .resizable()
                            .looping()
                            .animationSpeed(1.5)
                            .frame(width: 300 * xScale, height: 300 * xScale)
                            .offset(x: 0, y: 0)
                            .allowsHitTesting(false)
                }

                // String lines overlay (above button, taps pass through)
                ZStack {
                    Rectangle().fill(Color.white).frame(width: 4, height: 595 * yScale).offset(x: -58 * xScale, y: -199 * yScale)
                    Rectangle().fill(Color.white).frame(width: 4, height: 605 * yScale).offset(x: -35 * xScale, y: -192 * yScale)
                    Rectangle().fill(Color.white).frame(width: 4, height: 615 * yScale).offset(x: -11 * xScale, y: -190 * yScale)
                    Rectangle().fill(Color.white).frame(width: 4, height: 615 * yScale).offset(x:  11 * xScale, y: -190 * yScale)
                    Rectangle().fill(Color.white).frame(width: 4, height: 605 * yScale).offset(x:  35 * xScale, y: -192 * yScale)
                    Rectangle().fill(Color.white).frame(width: 4, height: 595 * yScale).offset(x:  58 * xScale, y: -199 * yScale)
                }
                .allowsHitTesting(false)

                // Border overlay
                Rectangle()
                    .stroke(Color.black, lineWidth: 2)
                    .ignoresSafeArea()
                if let voicings = recorder.voicings, !voicings.isEmpty {
                    let sorted = voicings.sorted {
                        ($0.filter { $0 != -1 && $0 != 0 }.min() ?? 0) <
                        ($1.filter { $0 != -1 && $0 != 0 }.min() ?? 0)
                    }
                    FretBoardDiagramView(fretArray: sorted[voicingIndex], stringSpacing: 23 * xScale, fretSpacing: 50 * yScale)
                        .scaleEffect(1.0)
                        .offset(y: -40 * yScale)
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.width < -50 {
                                        voicingIndex = min(voicingIndex + 1, sorted.count - 1)
                                    } else if value.translation.width > 50 {
                                        voicingIndex = max(voicingIndex - 1, 0)
                                    }
                                }
                        )
                        .onChange(of: recorder.voicings){_ in
                            voicingIndex = 0
                }
                        
                    }
            }
            .frame(width: w, height: h)
        }
    }
}

#Preview {
    let recorder = AudioController()
    recorder.voicings = [[0, 2, 2, 1, 0, 0]]  // Am as a test
    return ContentView(recorder: recorder)
}

