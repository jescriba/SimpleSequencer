//
//  Note.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/13/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation

struct Note {
    let keyToMidiNumber = ["C": 24, "C#": 25, "Db": 25, "D": 26, "D#": 27, "Eb": 27, "E": 28, "F": 29, "F#": 30, "Gb": 30, "G": 31, "G#": 32, "Ab": 32, "A": 33, "A#": 34, "Bb": 34, "B": 35]
  var key: String // Note letter i.e. A,A#,B,C etc...
  var octave: Int
  var velocity: Int

  /**
    Returns string representation of note. i.e. C4
  */
  func description() -> String {
      return "\(key)\(octave)"
  }

  /** 
    Returns midi key number corresponding to note. i.e. C3 -> 60  
  */
  func keyNumber() -> Int {
      return keyToMidiNumber[key]! + octave * 12
  }
    
}
