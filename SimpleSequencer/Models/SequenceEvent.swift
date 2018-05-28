//
//  SequenceEvent.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/9/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation

/**
    SequenceEvent corresponding to the MIDI track with a position and duration
*/
struct SequenceEvent {
    /// MIDI track index
    let track: Int
    /// Position of MIDI note in time
    let position: Double
    /// Duration of MIDI note to be played
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
