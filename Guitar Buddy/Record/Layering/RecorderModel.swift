//
//  RecorderModel.swift
//  Guitar Buddy
//
//  Created by Ashwin Rao on 10/2/26.
//

import AVFoundation
import Combine
import SwiftData

@Model
class RecorderModel {
    var fileName: String = ""
    var displayName: String = ""
    var createdDate: Date?
    @Relationship var parent: RecorderModel?
    @Relationship(deleteRule: .cascade, inverse: \RecorderModel.parent) var layers: [RecorderModel]?
    
    init(fileName: String, displayName: String, createdDate: Date?, parent: RecorderModel?, layers: [RecorderModel]){
        self.fileName = fileName
        self.displayName = displayName
        self.createdDate = createdDate
        self.parent = parent
        self.layers = layers
    }
    
}

