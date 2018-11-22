//
//  FXPresenter.swift
//  SimpleSequencer
//
//  Created by joshua on 11/18/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

class FXPresenter: NSObject {
    /**
     Configures the SynthFXTableViewCell by interfacing w/ the FXEngine
     and sets up the cell's stackview and fx sliders - then binds them to
     the AudioEngine state
    */
    static func present(fxCell: SynthFXTableViewCell, for indexPath: IndexPath) {
        guard let fxType = FXType(rawValue: indexPath.row) else { return }
        fxCell.titleLabel.text = fxType.title()
        switch fxType {
        case .reverb:
            presentReverb(fxCell: fxCell)
        case .delay:
            presentDelay(fxCell: fxCell)
        case .chorus:
            presentChorus(fxCell: fxCell)
        case .tremolo:
            presentTremolo(fxCell: fxCell)
        case .vibrato:
            presentVibrato(fxCell: fxCell)
        }
    }
    
    static func presentReverb(fxCell: SynthFXTableViewCell) {
        let horizontalStackView = addHorizontalStackViewToStackView(fxCell.contentStackView)
        // Add depth slider and details
        addSliderToStackView(horizontalStackView,
                             widthMultiplier: 0.45,
                             fx: FXParameterType.reverbDepth)
        // Add time slider and details
        addSliderToStackView(horizontalStackView,
                             widthMultiplier: 0.45,
                             fx: FXParameterType.reverbTime)
    }
    
    static func presentDelay(fxCell: SynthFXTableViewCell) {
        let horizontalStackView = addHorizontalStackViewToStackView(fxCell.contentStackView)
        // Add depth slider and details
        addSliderToStackView(horizontalStackView,
                             widthMultiplier: 0.45,
                             fx: FXParameterType.delayDepth)
        // Add time slider and details
        addSliderToStackView(horizontalStackView,
                             widthMultiplier: 0.45,
                             fx: FXParameterType.delayTime)
    }
    
    static func presentChorus(fxCell: SynthFXTableViewCell) {
        
    }
    
    static func presentTremolo(fxCell: SynthFXTableViewCell) {
        
    }
    
    static func presentVibrato(fxCell: SynthFXTableViewCell) {
        
    }
    
    static private func addLabelToStackView(_ stackView: UIStackView, title: String) {
        
    }
    
    static private func addHorizontalStackViewToStackView(_ stackView: UIStackView) -> UIStackView {
        let horizontalStackView = UIStackView(frame: .zero)
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 5
        stackView.addArrangedSubview(horizontalStackView)
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1),
            horizontalStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return horizontalStackView
    }
    
    static private func addSliderToStackView(_ stackView: UIStackView,
                                             widthMultiplier: CGFloat,
                                             fx: FXParameterType) {
        // setup title
        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = fx.title()
        titleLabel.textColor = .fxSliderSecondary
        titleLabel.font = UIFont(name: "Helvetica", size: 14)
        titleLabel.textAlignment = .center
        
        // setup slider
        let slider = CustomSlider(frame: .zero)
        slider.primaryColor = .fxSliderPrimary
        slider.secondaryColor = .fxSliderSecondary
        slider.tag = fx.rawValue
        slider.delegate = AudioEngine.shared.fxEngine
        let valueRange = fx.valueRange()
        slider.minValue = valueRange.0
        slider.maxValue = valueRange.1
        
        // setup contentView
        let titleSliderStackView = UIStackView(frame: .zero)
        titleSliderStackView.axis = .vertical
        titleSliderStackView.spacing = 5
        titleSliderStackView.addArrangedSubview(titleLabel)
        titleSliderStackView.addArrangedSubview(slider)
        stackView.addArrangedSubview(titleSliderStackView)
        titleSliderStackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleSliderStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: widthMultiplier),
            titleSliderStackView.heightAnchor.constraint(equalToConstant: 60),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            titleLabel.widthAnchor.constraint(equalToConstant: 100)
            ])
    }
    
}
