//
//  Note.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/13/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation

struct Note {
  let keyToMidiNumber = ["C": 24, "C#", "Db", "D", "D#", "Eb", "E", "F", "F#", "Gb", "G", "G#", "Ab", "A", "A#", "Bb", "B"]
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
      keyToMidiNumber[key] + octave * 12
  }
    
}
