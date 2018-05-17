//
//  SequencerCell.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/6/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

class SequencerCell: UICollectionViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    var note: Note = Note(key: "C", octave: 4, velocity: 60) {
      didSet {
        noteLabel.text = note.description()
      }
    }
    var shouldHideNote: Bool = false {
        didSet {
            if shouldHideNote {
                noteLabel.alpha = 0
            } else {
                noteLabel.alpha = 1
            }
        }
    }
    var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                mainView.backgroundColor = .solidPurple
            } else {
                mainView.backgroundColor = .purple
            }
        }
    }
    var isPlaying: Bool = false {
        didSet {
            guard isPlaying else {
                isEnabled = { isEnabled }()
                return
            }
            guard isEnabled else {
                mainView.backgroundColor = .darkPurple
                return
            }
            mainView.backgroundColor = .darkerPurple
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shouldHideNote =  { shouldHideNote }()
        isEnabled = { isEnabled }()
        note = { note }()
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
        
        backgroundView?.backgroundColor = .whitePurple
        mainView.layer.cornerRadius = 10
        mainView.layer.borderWidth = 1
        mainView.layer.borderColor = UIColor.customOrange.cgColor
    }
}
