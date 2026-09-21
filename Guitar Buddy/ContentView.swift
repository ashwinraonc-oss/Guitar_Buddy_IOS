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
                Group{
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: phase - 0.3),
                            .init(color: .white.opacity(0.7), location: phase),
                            .init(color: .clear, location: phase + 0.3),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
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
    @StateObject private var chordPlayer = ChordPlayer()

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let xScale = w / 390
            let yScale = h / 844
            
//            guard let voicingPlayed = recorder.voicings.first else {
//                print("No Chord Detected")
//            }

            ZStack {
                // Background
                Color(red: 210/255, green: 125/255, blue: 45/255)
                    .ignoresSafeArea()
                
                // Main content
                VStack {
                    Text("Chord Detector")
                        .font(.system(size: 40 * xScale))
                        .foregroundStyle(.clear)
                        .bold()
                        .offset(y: 5500 * yScale)
                        .background(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 92/255, green: 67/255, blue: 33/255))
                                .frame(width: 130 * xScale, height: 400 * yScale)
                                .offset(x: 0, y: 255 * yScale)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: 9)
                                        .offset(x: 0, y: 255 * yScale)
                                )
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 92/255, green: 67/255, blue: 33/255))
                                .frame(width: 130 * xScale, height: 400 * yScale)
                                .offset(x: 0, y: 255 * yScale)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.black)
                                        .frame(width: 130 * xScale, height: 400 * yScale)
                                        .offset(x: 5, y: 260 * yScale)
                                )
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 378 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 328 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 278 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 228 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 178 * yScale)
                            Rectangle().fill(Color.black).frame(width: 130 * xScale, height: 4).offset(x: 0, y: 128 * yScale)
                        }
                    

                    if let chord = recorder.detectedChord {
                        VStack {
                            HStack{
                                Text("Chord Detected:").font(.system(size: 25))
                                
                                Text(chord)
                                    .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(red: 88/255, green: 217/255, blue: 99/255))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black, lineWidth: 3)
                                    )
                                Button {
                                    guard let voicingPlayed = recorder.voicings, let firstVoicing = voicingPlayed.first else {
                                        print("No Chord Detected")
                                        return
                                    }
                                    chordPlayer.playChord(fretArray: firstVoicing)
                                } label: {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.black)
                                }
                            }
                            if let notes = recorder.detectedNotes {
                                HStack {
                                    Text("Notes Played:").font(.system(size: 25))
                                    Text("\(notes.joined(separator: ", "))")
                                        .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(red: 88/255, green: 217/255, blue: 99/255))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.black, lineWidth: 3)
                                        )
                                    Button {
                                        print(recorder.midiNotes.count)
                                        chordPlayer.playMIDI(midiArray: recorder.midiNotes)
                                    } label: {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundStyle(.black)
                                    }
                                }
                            }
                        }
                        .font(.system(size: 28 * xScale))
                        .bold()
                        .offset(x: 0, y: 595 * yScale)
                        .modifier(ShimmerModifier())
                    }
                    if recorder.detectedChord == nil && recorder.isDetecting == false{
                        Text("Detect Chord")
                            .font(.system(size: 30, weight: .bold))
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            .foregroundStyle(Color(red: 9/255, green: 21/255, blue: 64/255))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 0)
                            .background(Color(red: 88/255, green: 217/255, blue: 99/255))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                            .offset(x: 0, y: 600 * yScale)
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
                            .configure { view in
                                view.setValueProvider(
                                    ColorValueProvider(LottieColor(r: 88/255, g: 217/255, b: 99/255, a: 1)),
                                    keypath: AnimationKeypath(keypath: "**.Color")
                                )
                                view.setValueProvider(
                                    ColorValueProvider(LottieColor(r: 0, g: 0, b: 0, a: 1)),
                                    keypath: AnimationKeypath(keypath: "ellipse.**.Color")
                                )
                            }
                            .frame(width: 130 * xScale, height: 130 * xScale)
                            .offset(x: 0, y: 570 * yScale)
                            .padding(.top, 10)
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
                                .stroke(Color.black, lineWidth: 10.5)
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
                        .frame(width: 166 * xScale, height: 36 * yScale)
                        .offset(x: 0, y: 200 * yScale)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.8))
                                .frame(width: 165 * xScale, height: 30 * yScale)
                                .offset(x: 0 * xScale, y: 200 * yScale)
                        )
                    RoundedRectangle(cornerRadius: 20).fill(Color(red: 92/255, green: 67/255, blue: 33/255))
                        .frame(width: 160 * xScale, height: 28 * yScale)
                        .offset(x: 0, y: 200 * yScale)
                    Circle().fill(Color(red: 237/255, green: 219/255, blue: 171/255)).frame(width: 15 * xScale, height: 18 * xScale)
                        .offset(x: -58 * xScale, y: 200 * yScale)
                    Circle().fill(Color(red: 237/255, green: 219/255, blue: 171/255)).frame(width: 15 * xScale, height: 18 * xScale)
                        .offset(x: -35 * xScale, y: 200 * yScale)
                    Circle().fill(Color(red: 237/255, green: 219/255, blue: 171/255)).frame(width: 15 * xScale, height: 18 * xScale)
                        .offset(x: -11 * xScale, y: 200 * yScale)
                    Circle().fill(Color(red: 237/255, green: 219/255, blue: 171/255)).frame(width: 15 * xScale, height: 18 * xScale)
                        .offset(x:  11 * xScale, y: 200 * yScale)
                    Circle().fill(Color(red: 237/255, green: 219/255, blue: 171/255)).frame(width: 15 * xScale, height: 18 * xScale)
                        .offset(x:  35 * xScale, y: 200 * yScale)
                    Circle().fill(Color(red: 237/255, green: 219/255, blue: 171/255)).frame(width: 15 * xScale, height: 18 * xScale)
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
                    HStack(alignment: .top){
                        Button {
                            voicingIndex = max(voicingIndex - 1, 0)
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(red: 88/255, green: 217/255, blue: 99/255).opacity(1))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        } .opacity(voicingIndex == 0 ? 0.5 : 1)
                        .padding(.top, 150 * yScale)
                        FretBoardDiagramView(fretArray: sorted[min(voicingIndex, sorted.count - 1)], stringSpacing: 23 * xScale, fretSpacing: 50 * yScale)
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
                            .onChange(of: recorder.voicings){newVoicings in
                                guard let voicings = newVoicings, !voicings.isEmpty else {return}
                                chordPlayer.playChord(fretArray: voicings[0])
                                
                            }
                        Button {
                            voicingIndex = min(voicingIndex + 1, sorted.count - 1)
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(red: 88/255, green: 217/255, blue: 99/255).opacity(1))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        }
                        .padding(.top, 150 * yScale)
                        .opacity(voicingIndex == voicings.count - 1 ? 0.5 : 1)
                    }.offset(y: -40 * yScale)
                        .padding(.horizontal, 150 * xScale)

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
