//
//  AudioEngine.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/6/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import AudioKit
import AVFoundation

/// Delegate for handling AudioEngine state changes like tempo and playing
protocol AudioEngineDelegate {
    func didUpdateTempo(_ tempo: Double)
    func didUpdatePlaying(_ isPlaying: Bool)
}

/**
    Shared central singleton for managing the audio state of the app.
    Here you can interface with the sequencer and audio units as well as play state and tempo.
*/
class AudioEngine: NSObject {
    static let maxTempo: Double = 200
    static let minTempo: Double = 40
    static let shared = AudioEngine()
    var delegates = [AudioEngineDelegate?]()
    let fxEngine = FXEngine()
    let mixer = AKMixer()
    let synth = Synth()
    let sequencer = Sequencer()
    var tempo: Double = 100 {
        didSet {
          delegates.forEach { $0?.didUpdateTempo(tempo) }
          sequencer.setTempo(tempo)
        }
    }
    var isPlaying = false {
        didSet {
            delegates.forEach { $0?.didUpdatePlaying(isPlaying) }

            if isPlaying {
                sequencer.play()
            } else {
                sequencer.stop()
            }
        }
    }
    
    override init() {
        super.init()
        
        // TODO allow multiple input types to utilize sequencer
        sequencer.setupTracks()
        configureOutput()
    }
    
    func configureOutput() {
        sequencer.setMidiOutput(synth.oscillatorBank)
        // TODO allow for varying lengths
        sequencer.setLength()
        fxEngine.configureAudioSource(with: sequencer.midiNode)
        fxEngine.mixer >>> mixer
        AudioKit.output = mixer

        do {
            AKSettings.audioInputEnabled = true
            AKSettings.defaultToSpeaker = true
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(true)
            try AKSettings.setSession(category: .playback, with: .mixWithOthers)
            try AudioKit.start()
        } catch {
            print(error)
        }
    }
}
