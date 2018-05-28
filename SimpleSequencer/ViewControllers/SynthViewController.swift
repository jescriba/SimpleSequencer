//
//  SynthViewController.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/6/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

/**
    ViewController to manage UI for synth engine settings.
    This includes:
        - Volume envelope attack, decay, sustain, release (ADSR) settings
        - FX settings like reverb, delay, etc...
 */
class SynthViewController: UIViewController {
    init() {
        super.init(nibName: "SynthViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
