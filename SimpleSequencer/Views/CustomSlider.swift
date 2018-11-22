//
//  CustomSlider.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/6/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

protocol CustomSliderDelegate: NSObjectProtocol {
    func valueDidChange(newValue: Double, tag: Int)
}

/// Custom slider
class CustomSlider: UIView {
    @IBOutlet weak var secondaryWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondaryView: UIView!
    var primaryColor: UIColor = .tempoSliderPrimary {
        didSet {
            backgroundColor = primaryColor
        }
    }
    var secondaryColor: UIColor = .tempoSliderSecondary {
        didSet {
            secondaryView.backgroundColor = secondaryColor
        }
    }
    var maxValue: Double = 10
    var minValue: Double = 1
    var value: Double = 1 {
        didSet {
            delegate?.valueDidChange(newValue: value, tag: tag)
        }
    }
    weak var delegate: CustomSliderDelegate?
  
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

        updateSliderConstraint()
    }

    private func updateSliderConstraint(_ width: CGFloat? = nil) {
        let w = width ?? bounds.width * CGFloat((value - minValue) / (maxValue - minValue))
        
        secondaryWidthConstraint.constant = -1 * (bounds.width - w)
        layoutIfNeeded()
    }

    @IBAction func didPanOnView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.location(in: self).x
        guard translation > 0, translation <= bounds.width else { return }
        
        value = Double(translation / bounds.width) * (maxValue - minValue) + minValue
        updateSliderConstraint(translation)
    }
    
}
