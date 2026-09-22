//
//  BarVisualizer.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 9/22/26.
//  Followed tutorial: https://www.youtube.com/watch?v=vNy3qZi46p4
//

import SwiftUI
import Combine
import AVFoundation

struct BarVisualizer: View {
    let values: [Float]
    let barCount: Int
    var body: some View {
        
        GeometryReader{geo in
            let rawWidth = geo.size.width
            let rawHeight = geo.size.height
            let width = rawWidth.isFinite ? max(0, rawWidth) : 0
            let height = rawHeight.isFinite ? max(0, rawHeight) : 0
            let safeBarCount = max(1, barCount)
            let barSpacing: CGFloat = 1
            let totalSpacing = CGFloat(safeBarCount - 1) * barSpacing
            let availableWidth = max(0, width - totalSpacing)
            let barWdith = availableWidth / CGFloat(safeBarCount)
            let chunkSize = max(1, values.count / safeBarCount)
            
            let barValues: [Float] = (0..<safeBarCount).map { i in
            let start = i * chunkSize
                let end = min(start + chunkSize, values.count)
                if start > end {return 0}
                let slice = values[start..<end]
                return slice.reduce(0, +) / Float(slice.count)
        }
            
            HStack(alignment: .center, spacing: barSpacing){
                ForEach(0..<safeBarCount, id: \.self) { i in
                let base = CGFloat(barValues[i])
                    let v = base.isFinite ? base : 0
                    let capped = max(0.07, min(v,1))
                    let barHeight = max(0, min(height, capped * height))
                    let safeBarWidth = max(0, barWdith)
                    let yOffset = (height - barHeight) / 2
                    
                    Rectangle()
                        .fill(.primary.opacity(0.85))
                        .frame(width: safeBarWidth, height: barHeight)
                        .cornerRadius(safeBarWidth / 2)
                        .offset(y : yOffset)
                        
                    
                }
            }
            
        }
        
        
    }
}

