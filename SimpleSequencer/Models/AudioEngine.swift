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

protocol AudioEngineDelegate {
    func didUpdatePlaying(_ isPlaying: Bool)
}

class AudioEngine: NSObject {
    static let maxTempo: Double = 200
    static let minTempo: Double = 40
    static let shared = AudioEngine()
    var delegate: AudioEngineDelegate?
    let mixer = AKMixer()
    let sequencer = Sequencer()
    var isPlaying = false {
        didSet {
            delegate?.didUpdatePlaying(isPlaying)

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
        
        let audioSession = AVAudioSession.sharedInstance()
        _ = try? audioSession.setActive(true)
        _ = try? AKSettings.setSession(category: .playAndRecord, with: .mixWithOthers)
        
        AudioKit.output = mixer
        try? AudioKit.start()
//
//        // TODO Global effects?
//        [drums.mixer, keyboard.mixer, microphone.mixer] >>> instrumentMixer
//
//        // Set up recorder and player
//        recorder = try? AKNodeRecorder(node: mixer)
//        if let file = recorder?.audioFile {
//            player = try? AKAudioPlayer(file: file)
//            player?.looping = true
//        }
//
//        [instrumentMixer, AKMixer(player)] >>> mixer
//        AudioKit.output = mixer
//        try? AudioKit.start()
//
    }
}
