//
//  AudioRecorder.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 8/31/26.
//

import AVFoundation
import Combine

struct DetectionResult: Codable {
    let chord: String
    let score: Double
    let chord_notes: [Int]
    let chord_notes_names: [String]
    let chord_notes_names_midi: [Int]
    let notes: [Int]
    let note_names: [String]
    let root: Int?
    let voicing: [[Int]]
    let midi_notes: [Int]
}

struct DetectionPrev: Identifiable, Codable {
    var id: UUID
    let date: Date
    let detection: DetectionResult
}

class AudioController: NSObject, ObservableObject, AVAudioRecorderDelegate {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder?
    @Published var chordHistory: [DetectionPrev] = []
    @Published var historyIndex: Int? // which chordHistory entry is currently on screen
    @Published var detectedChord: String?
    @Published var voicings: [[Int]]?
    @Published var detectedNotes: [String]?
    @Published var isDetecting = false
    @Published var isRecording = false
    @Published var failedConnection = false
    @Published var midiNotes: [Int] = []
    @Published var chord_notes: [Int] = []
    @Published var chord_notes_names: [String] = []
    @Published var chord_notes_names_midi: [Int] = []
    @Published var root: Int?
    @Published var micPermissionDenied: Bool = false

    override init() {
        super.init()
//        guard !ProcessInfo.processInfo.environment.keys.contains("XCODE_RUNNING_FOR_PREVIEWS") else { return }
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try recordingSession.setActive(true)
            AVAudioApplication.requestRecordPermission {[weak self] hasPermission in
                DispatchQueue.main.async {
                    if hasPermission {
                        print("ACCEPTED")
                        self?.micPermissionDenied = false
                    } else {
                        print("DENIED")
                        self?.micPermissionDenied = true
                    }
                }

            }
        } catch {
            print("Failed to set up recording session: \(error)")
        }
    }

    func getDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = path[0]
        return documentDirectory
    }

    func startRecording() {
        failedConnection = false
        detectedChord = nil
        let filename = getDirectory().appendingPathComponent("recording.wav")
        let audioSettings: [String: Any] = [AVFormatIDKey: kAudioFormatLinearPCM,
                                          AVSampleRateKey: 44100.0,
                                    AVNumberOfChannelsKey: 1,
                                   AVLinearPCMBitDepthKey: 16]
        do {
            audioRecorder = try AVAudioRecorder(url: filename, settings: audioSettings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error)")
        }

    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        uploadRecording()
        isRecording = false
        isDetecting = true
        let url = getDirectory().appendingPathComponent("recording.wav")
           print("File exists: \(FileManager.default.fileExists(atPath: url.path))")
           print("File size: \(try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) bytes")
    }

    func uploadRecording() {
        let filename = getDirectory().appendingPathComponent("recording.wav")
        guard let backendURL = URL(string: "https://chord-ghost.onrender.com/detect") else {return}
        do {
            let fileData = try Data(contentsOf: filename)
            let boundary = UUID().uuidString
            var request = URLRequest(url: backendURL)
            request.timeoutInterval = 120
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            var body = Data()
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"recording.wav\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body

            URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        self.failedConnection = true
                        self.isDetecting = false
                    }
                    print("request failed: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                if let result = try? JSONDecoder().decode(DetectionResult.self, from: data) {
                    print(result.chord)
                    DispatchQueue.main.async {
                        print(result.chord)
                        self.isDetecting = false
                        self.apply(result)
                        let chordDate = Date()
                        let id = UUID()
                        let curr_chord = DetectionPrev(id: id, date: chordDate, detection: result)
                        self.chordHistory.append(curr_chord)
                        if self.chordHistory.count > 8{
                            self.chordHistory.removeFirst()
                        }
                        self.historyIndex = self.chordHistory.count - 1

                    }
                } else {
                    print("result from backend did not return properly")
                    DispatchQueue.main.async{
                        self.isDetecting = false
                        self.failedConnection = true
                    }
                }
            }.resume()

        } catch {
            print("error uploading audio")
            self.isDetecting = false
        }
    }
    // puts a detection result on screen. chord_notes_names must be set before chord_notes_names_midi,
    // because PianoController reads chord_notes_names when chord_notes_names_midi publishes
    func apply(_ result: DetectionResult) {
        detectedChord = result.chord
        voicings = result.voicing
        detectedNotes = result.note_names
        midiNotes = result.midi_notes
        chord_notes = result.chord_notes
        chord_notes_names = result.chord_notes_names
        chord_notes_names_midi = result.chord_notes_names_midi
        root = result.root
    }

    var canGoBack: Bool {
        (historyIndex ?? 0) > 0
    }

    var canGoForward: Bool {
        guard let index = historyIndex else { return false }
        return index < chordHistory.count - 1
    }

    func goBack() {
        guard let index = historyIndex, index > 0 else { return }
        show(index - 1)
    }

    func goForward() {
        guard let index = historyIndex, index < chordHistory.count - 1 else { return }
        show(index + 1)
    }

    private func show(_ index: Int) {
        historyIndex = index
        apply(chordHistory[index].detection)
    }

    func reset() {
        detectedChord = nil
        voicings = []
        detectedNotes = []
        midiNotes = []
        chord_notes = []
        chord_notes_names = []
        chord_notes_names_midi = []
        root = nil
        
    }
}
