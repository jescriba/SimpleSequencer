//
//  SequenceEvent.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/9/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation

struct SequenceEvent {
    let note: Int
    let position: Double
    let duration: Double
    
    init(note: Int, position: Double, duration: Double) {
        self.note = note
        self.position = position
        self.duration = duration
    }
}

extension SequenceEvent: Equatable {
    static func == (lhs: SequenceEvent, rhs: SequenceEvent) -> Bool {
        return lhs.note == rhs.note &&
            lhs.position == rhs.position &&
            lhs.duration == rhs.duration
    }
}
