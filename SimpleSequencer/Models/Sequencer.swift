//
//  Sequencer.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/9/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import AudioKit

/// Audio sequencer
class Sequencer: AKSequencer {
    static let maxTempo: Double = 260
    static let minTempo: Double = 30
    var maxMeasure: Double = 2.0
    var measure: Double = 0.5
    // Needed for managing event sequence state
    var events = [SequenceEvent]()
    var clearHandler: ((Int?) -> ())?
    internal private(set) var midiNode: AKMIDINode!
    private var midiOutput: MIDIEndpointRef!
    private var sequenceLength = AKDuration(beats: 4.0)
    
    override init() {
        super.init()
        setLength(sequenceLength)
        enableLooping()
    }
    
    /**
        Configure the MIDI output source
    */
    func setMidiOutput(_ node: AKPolyphonicNode) {
       // TODO change midi output source
        midiNode = AKMIDINode(node: node)
        midiOutput = midiNode.midiIn
        tracks.forEach({ $0.setMIDIOutput(midiOutput) })
    }
    
    /**
        Sets the loop info, number of loops, and sequence length
    */
    func setLength() {
        tracks.forEach({
            $0.setLoopInfo(sequenceLength, numberOfLoops: 0)
            $0.setLengthSoft(sequenceLength)
        })
    }
    
    /**
        Setups the MIDI tracks and properties like loop length
    */
    func setupTracks() {
        tracks.removeAll()
        
        
        _ = newTrack()
    }
    
    /**
        Adds sequencer item event for the specified note
    */
    func addSequenceItem(note: Note, indexPath: IndexPath, stepSize: Float) {
        let row = indexPath.row
        let position = Double(row) / stepSize
        let duration = Double(1.0) / stepSize
        tracks[0].add(noteNumber: MIDINoteNumber(note.keyNumber()), velocity: MIDIVelocity(note.velocity), position: AKDuration(beats: position), duration: AKDuration(beats: duration))
        events.append(SequenceEvent(track: note.keyNumber(), position: position, duration: duration))
    }
    
    /**
        Removes sequencer item event for the specified note
    */
    func removeSequenceItem(note: Note, indexPath: IndexPath, stepSize: Float) {
        let row = indexPath.row
        // wtf... the docs are confusing duration is the end AKDuration
        let position = Double(row) / stepSize
        let startDuration = AKDuration(beats: position)
        tracks[0].clearRange(start: startDuration, duration: (AKDuration(beats: (1.0 / stepSize)) + startDuration))

        let rawDuration = Double(1.0) / stepSize
        if let eventIndex = events.index(of: SequenceEvent(track: note.keyNumber(), position: position, duration: rawDuration)) {
            events.remove(at: eventIndex)
        }
    }
    
    /**
        Clears the sequencer events and triggers corresponding UI update
        - Parameter track: Midi track as Int to clear or clear all if none specified
    */
    func clear(_ track: Int? = nil) {
        clearHandler?(track)
        if let track = track {
            tracks[track].clear()
            events = events.filter { $0.track == track }
        } else {
            // If sequenceType is nil then clear all tracks
            for i in 0..<tracks.count {
                tracks[i].clear()
            }
            events.removeAll()
        }
    }
    
    /**
        Plays the sequencer
    */
    override func play() {
        super.rewind()
        super.play()
    }
    
    /**
        Stops the sequencer
    */
    override func stop() {
        super.stop()
    }
}
