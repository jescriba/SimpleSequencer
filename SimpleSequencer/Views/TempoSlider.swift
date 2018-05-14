//
//  TempoSlider.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/6/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

class TempoSlider: UIView {
    @IBOutlet weak var secondaryWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondaryView: UIView!
    var tempo: Double = AudioEngine.shared.sequencer.tempo {
        didSet {
            let ratio = CGFloat(tempo / (AudioEngine.maxTempo - AudioEngine.minTempo))
            secondaryWidthConstraint.constant = -1 * ratio * bounds.width
            layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func commonInit() {
        let view = loadXib()
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        view.layer.cornerRadius = 15
        layer.cornerRadius = 15
        secondaryView.layer.cornerRadius = 14
        
        tempo = AudioEngine.shared.sequencer.tempo
    }
    
    @IBAction func didPanOnView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.location(in: self).x
        guard translation > 0 else { return }
        
        if translation <= bounds.width {
            let possibleTempo = (1.0 - Double(abs(translation) / bounds.width)) * AudioEngine.maxTempo - AudioEngine.minTempo
            if possibleTempo < AudioEngine.maxTempo && possibleTempo > AudioEngine.minTempo {
                tempo = possibleTempo
                AudioEngine.shared.sequencer.setTempo(tempo)
            }
        }
    }
    
}
