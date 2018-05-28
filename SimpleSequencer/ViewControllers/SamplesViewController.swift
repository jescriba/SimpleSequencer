//
//  SamplesViewController.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/6/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

/// ViewController managing loading, editing, and selecting of the audio sample library
class SamplesViewController: UIViewController {
    init() {
        super.init(nibName: "SamplesViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
