//
//  Fretboard.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/3/26.
//

import SwiftUI
import AVFoundation

struct FretBoardDiagramView: View {
    let fretArray: [Int] //fret position for each string (6 strings)
    var stringSpacing: CGFloat = 40
    var fretSpacing: CGFloat = 74  // default for standalone use
    
    private var filteredNumbers: [Int] { fretArray.filter {$0 != -1 && $0 != 0}}
    private var minFret: Int {filteredNumbers.min() ?? 0}
    private var maxFret: Int {filteredNumbers.max() ?? 0}
    private var usesAbsolutePos: Bool {maxFret <= 3}
    
    var body: some View {
        let labelWidth: CGFloat = stringSpacing * 2
        let canvasWidth: CGFloat = stringSpacing * 6
        let topPad: CGFloat = fretSpacing * 0.5
        let canvasHeight: CGFloat = topPad + 5 * fretSpacing
        let fontSize: CGFloat = stringSpacing * 1.5
        let lineWidth: CGFloat = stringSpacing * 0.15

        VStack(spacing: stringSpacing * 0.2){
            HStack(spacing: 0){
                Text(" ")
                    .font(.system(size: fontSize))
                    .frame(width: labelWidth)
                    .opacity(0)
                HStack(spacing: 0) {
                    ForEach(0..<min(6, fretArray.count), id:\.self){i in
                        Text(marker(for: fretArray[i]))
                            .font(.system(size: fontSize))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color.red) //x's and o's color
                    }
                }
                .frame(width: canvasWidth, height: fontSize)
                Spacer()
                    .frame(width: labelWidth)
            }
            HStack(alignment: .top, spacing: 0){
                Text("\(minFret)")
                    .font(.system(size: fontSize))
                    .foregroundStyle(Color(red: 101/255, green: 67/255, blue: 33/255)) //fret label color
                    .frame(width: labelWidth)
                    .lineLimit(1)
                    .opacity(usesAbsolutePos ? 1 : 1)
                Canvas { context, size in
                    let topPad: CGFloat = fretSpacing * 0.5
                    let availHeight = size.height - topPad
                    let colWidth = size.width / 6
                    let rowHeight = availHeight / 5
                    let startX = 0.5 * colWidth
                    let endX = 5.5 * colWidth

                    for i in 0..<6 { //string lines
                        let x = (CGFloat(i) + 0.5) * colWidth
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: topPad))
                        path.addLine(to: CGPoint(x: x, y: topPad + 4 * rowHeight))
                        context.stroke(path, with: .color(.green), lineWidth: lineWidth)
                    }
                    for i in 0..<5 { //fret lines
                        let y = topPad + CGFloat(i) * rowHeight
                        var path = Path()
                        path.move(to: CGPoint(x: startX, y: y))
                        path.addLine(to: CGPoint(x: endX, y: y))
                        context.stroke(path, with: .color(.green), lineWidth: lineWidth)
                    }

                    for (j, fret) in fretArray.enumerated() {
                        guard fret != -1 && fret > 0 else { continue }
                        let rowFraction = usesAbsolutePos
                        ? (CGFloat(fret) - 0.5) / 5
                        : (CGFloat(fret - minFret) + 0.5) / 5
                        let x = (CGFloat(j) + 0.5) * colWidth
                        let y = topPad + rowFraction * availHeight
                        let r: CGFloat = stringSpacing * 0.35
                        let dotRect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                        context.fill(Path(ellipseIn: dotRect), with: .color(Color.yellow))
                    }
                }
                .frame(width: canvasWidth, height: canvasHeight)
                Spacer()
                    .frame(width: labelWidth)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, stringSpacing)
    }
    
    private func marker(for fret: Int) -> String{
        if fret == -1 {return "x"}
        if fret == 0 {return "o"}
        return ""
    }
    
    
}

struct VoicingsGridView: View {
    let voicings: [[Int]]
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 140), spacing: 20)
    ]
    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns, spacing: 20){
                ForEach(Array(voicings.enumerated()), id: \.offset){_,voicing in
                    FretBoardDiagramView(fretArray: voicing)
                        .containerRelativeFrame(.vertical)
                        .padding(.horizontal, 25)
                }
            }
            .padding()
        }
    }
}

struct VoicingsView: View {
    @ObservedObject var recorder: AudioController
    var body: some View {
        let sortedVoicings = (recorder.voicings ?? []).sorted { a, b in
            let minA = a.filter { $0 != -1 && $0 != 0 }.min() ?? 0
            let minB = b.filter { $0 != -1 && $0 != 0 }.min() ?? 0
            return minA < minB
        }
        VStack(spacing: 0){
            Text("Chord Diagrams:")
                .font(.system(size: 30, weight: .bold))
                .padding(.top, 120)
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    if recorder.voicings == nil || recorder.voicings!.isEmpty {
                        FretBoardDiagramView(fretArray: [0,0,0,0,0,0])
                            .containerRelativeFrame(.vertical)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    else{
                        ForEach(Array(sortedVoicings.enumerated()), id: \.offset) { _, voicing in
                                let _ = print(voicing)
                                FretBoardDiagramView(fretArray: voicing)
                                    .containerRelativeFrame(.vertical)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
        }
        .background(Color(red: 235/255, green: 55/255, blue: 34/255).ignoresSafeArea()).ignoresSafeArea()
    }
}

#Preview{
    VoicingsView(recorder: AudioController())
}

