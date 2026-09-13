//
//  ContentView.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 8/31/26.
//

import SwiftUI
import AVFoundation
import Lottie

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: phase - 0.3),
                        .init(color: .white.opacity(0.7), location: phase),
                        .init(color: .clear, location: phase + 0.3),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .blendMode(.plusLighter)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatCount(2, autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

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
                // Background
                Color(red: 210/255, green: 125/255, blue: 45/255)
                    .ignoresSafeArea()

                // Main content
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
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 378 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 328 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 278 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 228 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 178 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 128 * yScale)
                        }

                    if let chord = recorder.detectedChord {
                        VStack {
                            Text("Chord Detected:")
                            Text(chord)
                                .foregroundStyle(Color(red: 101/255, green: 67/255, blue: 33/255))
                            if let notes = recorder.detectedNotes {
                                HStack {
                                    Text("Notes:")
                                    Text(notes.joined(separator: ", "))
                                        .foregroundStyle(Color(red: 101/255, green: 67/255, blue: 33/255))
                                }
                            }
                        }
                        .font(.system(size: 28 * xScale))
                        .bold()
                        .offset(y: 585 * yScale)
                        .modifier(ShimmerModifier())
                    }

                    if recorder.failedConnection == true {
                        Text("Connection Failed")
                            .font(.system(size: 30 * xScale))
                            .foregroundStyle(.red)
                            .bold()
                            .offset(y: 550 * yScale)
                    }

                    if recorder.isDetecting == true {
                        LottieView(animation: .named("loading"))
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
                                .fill(Color(red: 14/255, green: 17/255, blue: 17/255))
                                .frame(
                                    width: recorder.isRecording ? 30 * xScale : 70 * xScale,
                                    height: recorder.isRecording ? 30 * xScale : 70 * xScale
                                )
                                .animation(.easeInOut(duration: 0.3), value: recorder.isRecording)
                        }
                    }
                    .scaleEffect(3.0)
                    .offset(x: 0, y: -380 * yScale)
                }
                .frame(maxWidth: .infinity)

                // Ripple animation while recording
                if recorder.isRecording {
                    LottieView(animation: .named("Ripple Red"))
                        .playing(.fromProgress(0, toProgress: 1, loopMode: .autoReverse))
                        .resizable()
                        .looping()
                        .animationSpeed(1.5)
                        .frame(width: 300 * xScale, height: 300 * xScale)
                        .allowsHitTesting(false)
                        .offset(x: 0, y: 0)
                }

                // String lines overlay
                ZStack {
                    RoundedRectangle(cornerRadius: 20).fill(Color.black)
                        .frame(width: 160 * xScale, height: 28 * yScale)
                        .offset(x: 0, y: 200 * yScale)
                    Circle().fill(Color(red: 53/255, green: 40/255, blue: 20/255)).frame(width: 15 * xScale, height: 18 * xScale)
                        .offset(x: -58 * xScale, y: 200 * yScale)
                    Circle().fill(Color(red: 53/255, green: 40/255, blue: 20/255)).frame(width: 15 * xScale, height: 18 * xScale)
                        .offset(x: -35 * xScale, y: 200 * yScale)
                    Circle().fill(Color(red: 53/255, green: 40/255, blue: 20/255)).frame(width: 15 * xScale, height: 18 * xScale)
                        .offset(x: -11 * xScale, y: 200 * yScale)
                    Circle().fill(Color(red: 53/255, green: 40/255, blue: 20/255)).frame(width: 15 * xScale, height: 18 * xScale)
                        .offset(x:  11 * xScale, y: 200 * yScale)
                    Circle().fill(Color(red: 53/255, green: 40/255, blue: 20/255)).frame(width: 15 * xScale, height: 18 * xScale)
                        .offset(x:  35 * xScale, y: 200 * yScale)
                    Circle().fill(Color(red: 53/255, green: 40/255, blue: 20/255)).frame(width: 15 * xScale, height: 18 * xScale)
                        .offset(x:  58 * xScale, y: 200 * yScale)
                }
                //strings
                ZStack {
                    Rectangle().fill(Color.white).frame(width: 4, height: 783 * yScale).offset(x: -58 * xScale, y: -199 * yScale)
                    Rectangle().fill(Color.white).frame(width: 4, height: 770 * yScale).offset(x: -35 * xScale, y: -192 * yScale)
                    Rectangle().fill(Color.white).frame(width: 4, height: 765 * yScale).offset(x: -11 * xScale, y: -190 * yScale)
                    Rectangle().fill(Color.white).frame(width: 4, height: 765 * yScale).offset(x:  11 * xScale, y: -190 * yScale)
                    Rectangle().fill(Color.white).frame(width: 4, height: 770 * yScale).offset(x:  35 * xScale, y: -192 * yScale)
                    Rectangle().fill(Color.white).frame(width: 4, height: 783 * yScale).offset(x:  58 * xScale, y: -199 * yScale)

                }
                .allowsHitTesting(false)
                
                //guitar nuts

                // Border overlay
                Rectangle()
                    .stroke(Color.black, lineWidth: 2)
                    .ignoresSafeArea()

                // Fretboard diagram overlay
                if let voicings = recorder.voicings, !voicings.isEmpty {
                    let sorted = voicings.sorted {
                        ($0.filter { $0 != -1 && $0 != 0 }.min() ?? 0) <
                        ($1.filter { $0 != -1 && $0 != 0 }.min() ?? 0)
                    }
                    FretBoardDiagramView(fretArray: sorted[voicingIndex], stringSpacing: 23 * xScale, fretSpacing: 50 * yScale)
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
                        .onChange(of: recorder.voicings) { _ in
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
    recorder.voicings = [[0, 2, 2, 1, 0, 0]]
    return ContentView(recorder: recorder)
}
