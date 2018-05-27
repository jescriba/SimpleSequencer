//
//  Extensions.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 4/28/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit
import SVGKit

extension UIColor {
    static let whitePurple = UIColor(red:0.95, green:0.93, blue:1.00, alpha:1.0) // #F3ECFF
    static let lightPurple = UIColor(red:0.89, green:0.82, blue:0.99, alpha:1.0) // #E2D2FD
    static let purple = UIColor(red:0.55, green:0.40, blue:0.63, alpha:1.0) // #8B66A0
    static let solidPurple = UIColor(red:0.35, green:0.09, blue:0.78, alpha:1.0) // #5918C7
    static let darkPurple = UIColor(red:0.18, green:0.03, blue:0.26, alpha:1.0) // #2E0743
    static let darkerPurple = UIColor(red:0.14, green:0.00, blue:0.22, alpha:1.0) // #240037
    static let shadedPurple = UIColor(red:0.35, green:0.16, blue:0.45, alpha:1.0) // #582A72
    static let burgundy = UIColor(red:0.40, green:0.02, blue:0.02, alpha:1.0) // #650505
    static let customGreen = UIColor(red:0.24, green:0.90, blue:0.26, alpha:1.0) // #3CE542
    static let customRed = UIColor(red:1.00, green:0.25, blue:0.25, alpha:1.0) // #ff4040
    static let customOrange = UIColor(red:1.00, green:0.60, blue:0.18, alpha:1.0) // #FF982F
    
    // Update these colors
    static let keyOn = UIColor(red:0.41, green:0.50, blue:0.97, alpha:1.0)
    static let octaveBorder = UIColor(red:0.80, green:0.63, blue:0.80, alpha:1.0)
    static let octaveBorderSelected = UIColor(red:0.90, green:0.63, blue:0.80, alpha:1.0)
    static let sequencerCell = UIColor(red:1.00, green:0.58, blue:0.12, alpha:1.0)
    static let sequencerCellSelected = UIColor(red:1.00, green:0.43, blue:0.33, alpha:1.0)
    static let sequencerCellPartialSelected = UIColor(red:1.00, green:0.48, blue:0.33, alpha:1.0)
    static let sequencerCellBorder = UIColor(red:1.00, green:0.43, blue:0.13, alpha:1.0)
    static let paneBorder = UIColor(red:0.60, green:0.29, blue:0.60, alpha:1.0)
    static let paneBorderSelected = UIColor(red:0.70, green:0.29, blue:0.60, alpha:1.0)
    static let playOn = UIColor(red:1.00, green:0.39, blue:0.43, alpha:1.0)
    static let playOff = UIColor(red:0.8, green:0.39, blue:0.43, alpha:1.0)
    static let tapTempo = UIColor(red:0.40, green:0.78, blue:0.55, alpha:1.0)
    static let tapTempoSelected = UIColor(red:0.40, green:0.69, blue:0.55, alpha:1.0)
    static let pastelYellow = UIColor(red:1.00, green:1.00, blue:0.60, alpha:1.0)
    static let pastelOrange = UIColor(red:1.00, green:0.43, blue:0.13, alpha:1.0)
    static let pastelBlue =  UIColor(red:0.62, green:0.79, blue:0.93, alpha:1.0)
    static let pastelPurple = UIColor(red:0.78, green:0.72, blue:0.89, alpha:1.0)
    static let pastelRed = UIColor(red:1.00, green:0.41, blue:0.38, alpha:1.0)
    static let pastelGreen = UIColor(red:0.47, green:0.87, blue:0.47, alpha:1.0)
}

extension UIImage {
    static func fromSVG(named: String) -> UIImage {
        return SVGKImage(named: named).uiImage
    }
}

extension UIView {
    func loadXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}

extension String {
    func isPreferredNote() -> Bool {
        guard self.contains("#") || self.contains("b") else {
            return true
        }
        
        guard ["Db", "D#", "Gb", "A#"].contains(self) else {
            return true
        }
        
        return false
    }
}

extension Collection where Iterator.Element == TimeInterval
{
    func average() -> TimeInterval {
        return self.reduce(0, +) / Double(self.count as! Int)
    }
}

extension Collection where Iterator.Element == SequenceEvent {
    func indexPathsFor(timeDivision: TimeDivision) -> [GenericIndexPath] {
        var indexPaths = [GenericIndexPath]()
        let stepSize = Double(timeDivision.numberOfSteps()) / 4.0
        for event in self {
            let possibleRow = event.position * stepSize
            // Check if integer
            if floor(possibleRow) == possibleRow {
                let indexPath = IndexPath(row: Int(possibleRow), section: event.track)
                indexPaths.append(indexPath)
            } else {
                let indexPath = PartialIndexPath(row: possibleRow, section: event.track)
                indexPaths.append(indexPath)
            }
        }
        
        return indexPaths
    }
}
