//
//  Note.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/13/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation

struct Note {
    static let keyToMidiNumber = ["C": 24, "C#": 25, "Db": 25, "D": 26, "D#": 27, "Eb": 27, "E": 28, "F": 29, "F#": 30, "Gb": 30, "G": 31, "G#": 32, "Ab": 32, "A": 33, "A#": 34, "Bb": 34, "B": 35]
    var key: String // Note letter i.e. A,A#,B,C etc...
    var octave: Int
    var velocity: Int
    private static var _all: [Note]?
    static var all: [Note] {
        get {
            guard let a = _all else {
                let keys = [String](keyToMidiNumber.keys).sorted().filter { $0.isPreferredNote() }
                _all = [Note]()
                for i in 0...88 {
                    _all!.append(Note(key: keys[i % 12], octave: i / 12, velocity: 60))
                }
                return _all!
            }
            
            return a
        }
    }

    /**
        String description of note. i.e. C3, Db4, etc..
    */
    func description() -> String {
        return "\(key)\(octave)"
    }

    /** 
      Returns midi key number corresponding to note. i.e. C3 -> 60  
    */
    func keyNumber() -> Int {
        return Note.keyToMidiNumber[key]! + octave * 12
    }
    
}
