//
//  MeasureMeter.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/6/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

class MeasureMeter: UIView {
    @IBOutlet weak var playheadView: UIView!
    @IBOutlet weak var playheadConstraint: NSLayoutConstraint!
    
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
        playheadView.layer.cornerRadius = 5

        updatePlayheadConstraint()
    }

    private func updatePlayheadConstraint(withTranslation translation: CGFloat? = nil) {
        let maxPosition = bounds.width - playheadView.bounds.midX
        let t = translation ?? maxPosition * CGFloat(AudioEngine.shared.sequencer.measure) / CGFloat(AudioEngine.shared.sequencer.maxMeasure)
        playheadConstraint.constant = t
        layoutIfNeeded()
    }

    @IBAction func didPanOnView(_ sender: UIPanGestureRecognizer) {
        let maxPosition = bounds.width - playheadView.bounds.midX
        let translation = sender.location(in: self).x
        guard translation > 0, translation <= maxPosition else { return }
        let measure = Double(translation / maxPosition) * AudioEngine.shared.sequencer.maxMeasure
        AudioEngine.shared.sequencer.measure = measure

        updatePlayheadConstraint(withTranslation: translation)
    }
}
