//
//  SequencerViewController.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 4/28/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

class SequencerViewController: UIViewController {
    init() {
        super.init(nibName: "SequencerViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AudioEngine.shared.delegates.append((view as! SequencerView))
    }
}
