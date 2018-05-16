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
    @IBOutlet weak var playheadCenterConstraint: NSLayoutConstraint!
    
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

        updatePlayheadCenterConstraint()
    }

    private func updatePlayheadCenterConstraint(withTranslation translation: CGFloat? = nil) {
        guard let t = translation else {
            let t = bounds.width * Double(AudioEngine.shared.sequencer.measure) / Double(AudioEngine.shared.sequencer.maxMeasure)
        }

        playheadCenterConstraint.constant = t
        layoutIfNeeded()
    }

    @IBAction func didPanOnView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.location(in: self).x
        guard translation > 0, translation <= bounds.width else { return }
        measure = Int(Double(translation / bounds.width) * AudioEngine.shared.sequencer.maxMeasure)
        AudioEngine.shared.sequencer.measure = measure

        updatePlayheadCenterConstraint(withTranslation: translation)
    }
}
