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
    private let sequenceLength = AKDuration(beats: 4.0)
    // Needed for managing event sequence state
    var events = [SequenceEvent]()
    var clearHandler: ((Int?) -> ())?
    let synth = Synth()
    
    override init() {
        super.init()
        setLength(sequenceLength)
        enableLooping()
    }
    
    /**
        Changes the MIDI output source
    */
    func changeOutput() {
       // TODO change midi output source
    }
    
    /**
        Setups the MIDI tracks and properties like loop length
    */
    func setupTracks() {
        tracks.removeAll()
        
        _ = newTrack()
        tracks[0].setLoopInfo(sequenceLength, numberOfLoops: 0)
        tracks[0].setLength(sequenceLength)
        let midi = AudioKit.midi
        midi.openOutput()
        let midiNode = AKMIDINode(node: synth.oscillatorBank)
        tracks[0].setMIDIOutput(midiNode.midiIn)
        //tracks[0].setMIDIOutput((midi.endpoints.first?.value)!)
        // TODO dynamic sequence Length
//        tracks[SequenceType.kick.rawValue].setLoopInfo(sequenceLength, numberOfLoops: 0)
//        tracks[SequenceType.kick.rawValue].setLength(sequenceLength)
//        tracks[SequenceType.kick.rawValue].setMIDIOutput(kick.midiIn)
//
//        _ = newTrack()
//        tracks[SequenceType.snare.rawValue].setLoopInfo(sequenceLength, numberOfLoops: 0)
//        tracks[SequenceType.snare.rawValue].setLength(sequenceLength)
//        tracks[SequenceType.snare.rawValue].setMIDIOutput(snare.midiIn)
//
//        _ = newTrack()
//        tracks[SequenceType.closedHH.rawValue].setLoopInfo(sequenceLength, numberOfLoops: 0)
//        tracks[SequenceType.closedHH.rawValue].setLength(sequenceLength)
//        tracks[SequenceType.closedHH.rawValue].setMIDIOutput(closedHH.midiIn)
//
//        _ = newTrack()
//        tracks[SequenceType.openHH.rawValue].setLoopInfo(sequenceLength, numberOfLoops: 0)
//        tracks[SequenceType.openHH.rawValue].setLength(sequenceLength)
//        tracks[SequenceType.openHH.rawValue].setMIDIOutput(openHH.midiIn)
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
