//
//  Sequencer.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/9/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import AudioKit

// TODO Allow for adjustable source
class Sequencer: AKSequencer {
    static let maxTempo: Double = 260
    static let minTempo: Double = 30
    var maxMeasure: Double = 2.0
    var measure: Double = 0.5
    private let sequenceLength = AKDuration(beats: 4.0)
    // Needed for managing event sequence state
    var events = [SequenceEvent]()
    
    override init() {
        super.init()
        setLength(sequenceLength)
        enableLooping()
    }
    
    func setupTracks() {
        tracks.removeAll()
        
        _ = newTrack()
        tracks[0].setLoopInfo(sequenceLength, numberOfLoops: 0)
        tracks[0].setLength(sequenceLength)
        let midi = AudioKit.midi
        midi.openOutput()
//        tracks[0].setMIDIOutput((midi.endpoints.first?.value)!)
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
    
    func addSequenceItem(indexPath: IndexPath, stepSize: Float) {
        //let sequenceType = SequenceType(rawValue: indexPath.section)
//        guard let type = sequenceType else { return }
        setupTracks()
        let row = indexPath.row
        let position = Double(row) / stepSize
        let duration = Double(1.0) / stepSize
        tracks[0].add(noteNumber: 60, velocity: 90, position: AKDuration(beats: position), duration: AKDuration(beats: duration))
        events.append(SequenceEvent(note: 60, position: position, duration: duration))
    }
    
    func removeSequenceItem(indexPath: IndexPath, stepSize: Float) {
       // let sequenceType = SequenceType(rawValue: indexPath.section)
//        guard let type = sequenceType else { return }
//        let row = indexPath.row
//        // wtf... the docs are confusing duration is the end AKDuration
//        let position = Double(row) / stepSize
//        let startDuration = AKDuration(beats: position)
//        tracks[type.rawValue].clearRange(start: startDuration, duration: (AKDuration(beats: (1.0 / stepSize)) + startDuration))
//
//        let rawDuration = Double(1.0) / stepSize
//        if let eventIndex = events.index(of: SequenceEvent(sequenceType: type, position: position, duration: rawDuration)) {
//            events.remove(at: eventIndex)
//        }
    }
    
//    func clear(_ sequenceType: SequenceType? = nil) {
//        if let type = sequenceType {
//            tracks[type.rawValue].clear()
//            events = events.filter { $0.sequenceType == type }
//        } else {
//            // If sequenceType is nil then clear all tracks
//            for i in 0..<tracks.count {
//                tracks[i].clear()
//            }
//            events.removeAll()
//        }
//    }
    
    override func play() {
        super.rewind()
        super.play()
    }
    
    override func stop() {
        super.stop()
    }
}
