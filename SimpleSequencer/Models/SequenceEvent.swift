//
//  SequenceEvent.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/9/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation

struct SequenceEvent {
    let track: Int
    let position: Double
    let duration: Double
    
    init(track: Int, position: Double, duration: Double) {
        self.track = track
        self.position = position
        self.duration = duration
    }
}

extension SequenceEvent: Equatable {
    static func == (lhs: SequenceEvent, rhs: SequenceEvent) -> Bool {
        return lhs.track == rhs.track &&
            lhs.position == rhs.position &&
            lhs.duration == rhs.duration
    }
}
