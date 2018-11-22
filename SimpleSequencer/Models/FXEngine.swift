//
//  FXEngine.swift
//  SimpleSequencer
//
//  Created by joshua on 11/18/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import AudioKit

enum FXType: Int {
    case reverb, delay, chorus, tremolo, vibrato
    
    func title() -> String {
        switch self {
        case .reverb:
            return "reverb"
        case .delay:
            return "delay"
        case .chorus:
            return "chorus"
        case .tremolo:
            return "tremolo"
        case .vibrato:
            return "vibrato"
        }
    }
}

enum FXParameterType: Int {
    case reverbDepth, reverbTime, delayDepth, delayTime
    
    func title() -> String {
        switch self {
        case .reverbDepth, .delayDepth:
            return "depth"
        case .reverbTime, .delayTime:
            return "time"
        }
    }
    
    // Return minVal and maxValue for parameter type
    func valueRange() -> (Double, Double) {
        switch self {
        case .reverbDepth, .delayDepth:
            return (1, 10)
        case .reverbTime, .delayTime:
            return (1, 10)
        }
    }
}

class FXEngine: NSObject {
    static let numberOfFX = 5
    let mixer = AKMixer()
    internal private(set) var audioSource: AKNode?
    var reverb: AKReverb2?
    var delay: AKDelay?
    var chorus: AKChorus?
    var tremolo: AKTremolo?
    
    override init() {
        super.init()
    }
    
    func configureAudioSource(with audioNode: AKNode) {
        audioSource = audioNode
        
        // Confgure audio source with current FX state
        // TODO @joshua
        let verb = AKReverb2(audioNode)
        verb.dryWetMix = 0.5
        verb.decayTimeAt0Hz = 7
        verb.decayTimeAtNyquist = 11
        verb.randomizeReflections = 600
        verb.gain = 1
        verb >>> mixer
    }
}

extension FXEngine: CustomSliderDelegate {
    func valueDidChange(newValue: Double, tag: Int) {
        // TODO @joshua
    }
}
