//
//  SettingsViewController.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/6/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

/**
    ViewController representing UI to manage settings.
    This includes:
        * MIDI Output (external device, internal synth, or sampler)
        * Number of musical measures in the sequencer
        * Time signature - 3/4 or 4/4 [wip]
 */
class SettingsViewController: UIViewController {
    init() {
        super.init(nibName: "SettingsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
