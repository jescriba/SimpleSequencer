//
//  SynthADSRView.swift
//  SimpleSequencer
//
//  Created by joshua on 11/10/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit
import AudioKit
import AudioKitUI

class SynthADSRView: UIView {
    @IBOutlet weak var adsrView: AKADSRView!
    
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
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        adsrView.backgroundColor = .customLightBlue
        adsrView.tintColor = .customLightBlue
        adsrView.bgColor = .customLightBlue
        adsrView.curveColor = .customLightBlue
        adsrView.attackColor = .customBlueGreen
        adsrView.decayColor = .customLightBlueGreen
        adsrView.sustainColor = .customBlueGreen
        adsrView.releaseColor = .customLightBlueGreen
    }
}
