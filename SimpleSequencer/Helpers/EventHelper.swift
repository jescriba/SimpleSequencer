//
//  EventHelper.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/27/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation

/// Helper class for managing SequenceEvent logic
class EventHelper: NSObject {
    /**
        Determines if the SequencerCell with the specified note, timeDivision, and row should be enabled
         - Parameter note: Note that should be check in sequence event state
         - Parameter timeDivision: TimeDivision for what a 'row''s beat would translate into an audio position
         - Parameter row: Int representing the sequencer 'row' or 'column'
         - Returns: A bool representing if the note at the specified row should be enabled in UI due to the backing SequenceEvent state
    */
    static func isEnabled(note: Note, timeDivision: TimeDivision, row: Int) -> Bool {
        let stepSize = Double(timeDivision.numberOfSteps()) / 4.0
        let position = Double(row) / stepSize
        let events = AudioEngine.shared.sequencer.events.filter {
            $0.track == note.keyNumber() && $0.position == position
        }
        return events.count > 0
    }
    
//    /**
//     Determines if the SequencerCell with the specified note, timeDivision, and row should be partially enabled
//     - Parameter note: Note that should be check in sequence event state
//     - Parameter timeDivision: TimeDivision for what a 'row''s beat would translate into an audio position
//     - Parameter row: Int representing the sequencer 'row' or 'column'
//     - Returns: A bool representing if the note at the specified row should be partially enabled in UI due to the backing SequenceEvent state
//     */
//    static func isPartiallyEnabled() -> Bool {
//        
//    }
}
