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
    static let solidPurple2 = UIColor(red:0.42, green:0.09, blue:0.78, alpha:1.0) // #6C18C7
    static let darkPurple = UIColor(red:0.18, green:0.03, blue:0.26, alpha:1.0) // #2E0743
    static let darkerPurple = UIColor(red:0.14, green:0.00, blue:0.22, alpha:1.0) // #240037
    static let shadedPurple = UIColor(red:0.35, green:0.16, blue:0.45, alpha:1.0) // #582A72
    static let burgundy = UIColor(red:0.40, green:0.02, blue:0.02, alpha:1.0) // #650505
    static let customGreen = UIColor(red:0.24, green:0.90, blue:0.26, alpha:1.0) // #3CE542
    static let customRed = UIColor(red:1.00, green:0.25, blue:0.25, alpha:1.0) // #ff4040
    static let customOrange = UIColor(red:1.00, green:0.60, blue:0.18, alpha:1.0) // #FF982F
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
        return self.reduce(0, +) / TimeInterval(self.count)
    }
}

extension Collection where Iterator.Element == SequenceEvent {
    func indexPathsFor(timeDivision: TimeDivision, visibleTracks: [Int]) -> [GenericIndexPath] {
        var indexPaths = [GenericIndexPath]()
        let stepSize = Double(timeDivision.numberOfSteps()) / 4.0
        for event in self {
            guard let section = visibleTracks.index(of: event.track) else {
                continue
            }
            let possibleRow = event.position * stepSize
            // Check if integer
            if floor(possibleRow) == possibleRow {
                let indexPath = IndexPath(row: Int(possibleRow), section: section)
                indexPaths.append(indexPath)
            } else {
                let indexPath = PartialIndexPath(row: possibleRow, section: section)
                indexPaths.append(indexPath)
            }
        }
        
        return indexPaths
    }
}
