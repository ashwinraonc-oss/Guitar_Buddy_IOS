//
//  RootViewUpdated.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/13/26.
//

import SwiftUI
import Foundation

struct RootViewUpdated: View {
    @State private var isLoading = false
    @State var selectedTab = 0
    @State var dimmed = false
    @StateObject private var recorder = AudioController()
    @StateObject private var keys: PianoController
    @StateObject private var tuner = TunerController()
    @StateObject private var progression = ProgressionController()
    @StateObject private var tunerPlayer = ChordPlayer()
    
    init(){
        let recorder = AudioController()
        self._recorder = StateObject(wrappedValue: recorder)
        self._keys = StateObject(wrappedValue: PianoController(audioController: recorder))
    }

    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                MiniRecorderView()
                    .tabItem {
                        Image(systemName: "microphone")
                        Text("Record")
                    }
                    .tag(3)
                ProgressionView(progression: progression)
                    .tabItem {
                        Image(systemName: "lightbulb.max.fill")
                        Text("Create")
                    }
                    .tag(1)
                ContentView(keys: keys, recorder: recorder)
                    .tabItem {
                        Image(systemName: "ear.badge.waveform")
                        Text("Detect")
                    }
                    .tag(0)
                TunerView(tuner: tuner, player: tunerPlayer)
                    .tabItem {
                        Image(systemName: "tuningfork")
                        Text("Tune")
                    }
                    .tag(2)
            }
        }
    }
}

#Preview {
    RootViewUpdated()
}
