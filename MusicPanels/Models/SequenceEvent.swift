//
//  SequenceEvent.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 3/13/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation

struct SequenceEvent {
    let sequenceType: SequenceType
    let position: Double
    let duration: Double
    
    init(sequenceType: SequenceType, position: Double, duration: Double) {
        self.sequenceType = sequenceType
        self.position = position
        self.duration = duration
    }
}

extension SequenceEvent: Equatable {
    static func == (lhs: SequenceEvent, rhs: SequenceEvent) -> Bool {
        return lhs.sequenceType == rhs.sequenceType &&
                lhs.position == rhs.position &&
                lhs.duration == rhs.duration
    }
}
