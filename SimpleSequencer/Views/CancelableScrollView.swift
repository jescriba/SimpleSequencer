//
//  CancelableScrollView.swift
//  SimpleSequencer
//
//  Created by joshua on 11/18/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

class CancelableScrollView: UIScrollView {
    var viewsShouldntCancelTouches = [UIView]()
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        print("touchesshouldcancel")
        if let _ = viewsShouldntCancelTouches.first(where: { view.isDescendant(of: $0 )}) {
            return false
        }
        return super.touchesShouldCancel(in: view)
    }
    
    override var canCancelContentTouches: Bool {
        get {
            return false
        } set { }
    }
    
    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        if let _ = viewsShouldntCancelTouches.first(where: { view.isDescendant(of: $0 )}) {
            return false
        }
        return super.touchesShouldBegin(touches, with: event, in: view)
    }
    
}
