//
//  SequencerView.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 4/28/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

// TODO Handle for more time signatures than 4/4
enum TimeDivision: Int {
    case quarter, quarterTriplet, eighth, eighthTriplet, sixteenth
    
    func numberOfSteps() -> Int {
        switch self {
        case .quarter:
            return 4
        case .quarterTriplet:
            return 6
        case .eighth:
            return 8
        case .eighthTriplet:
            return 12
        case .sixteenth:
            return 16
        }
    }
    
    static func count() -> Int {
        return 5
    }
}

class SequencerView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var timeDivision: TimeDivision = .eighth
    private var shouldUpdateMarker = false
    private var markerIndex = 0 {
        didSet {
            shouldUpdateMarker = true
        }
    }
    private var currentBeatTimer = Timer()
    private var isPlaying = false {
        didSet {
            currentBeatTimer.invalidate()
            if isPlaying {
                currentBeatTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.001), target: self, selector: #selector(updateCurrentPositionMarker(clear:)), userInfo: nil, repeats: true)
                return
            }
            updateCurrentPositionMarker(clear: true)
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

        // Update CollectionViewCell ItemSize if the Pane changes
        collectionView.collectionViewLayout.invalidateLayout()
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
        
        collectionView.register(SequencerCell.self, forCellWithReuseIdentifier: "SequencerCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.layer.cornerRadius = 5
    }
    
    @IBAction func didPinchOnCollectionView(_ sender: UIPinchGestureRecognizer) {
        // Preventing changed states from constantly zooming in/out for now
        guard sender.state == .began else {return}

        // scale < 1 pinch out/open aka zoom out - larger time denomination 1/8 -> 1/4t -> 1/4 -> 1/2
        if sender.scale < 1 {
            var newRawValue = (timeDivision.rawValue - 1) % TimeDivision.count()
            if timeDivision.rawValue == 0 {
                newRawValue = TimeDivision.count() - 1
            }
            timeDivision = TimeDivision(rawValue: newRawValue)!

            // Update the event sequence to the new time division
            updateCollectionViewEventState()
            return
        }

        // scale > 1 Pin inch aka zoom in - smaller time denomination i.e. 1/8 -> 1/8t > 1/16
        if sender.scale > 1 {
            timeDivision = TimeDivision(rawValue: (timeDivision.rawValue + 1) % TimeDivision.count())!

            // Update the event sequence to the new time division
            updateCollectionViewEventState()
            return
        }
    }
    
    @objc func updateCurrentPositionMarker(clear: Bool = false) {
        if markerIndex != Int(AudioEngine.shared.sequencer.currentRelativePosition.beats * Double(timeDivision.numberOfSteps()) / 4.0) {
            markerIndex += 1
            markerIndex %= timeDivision.numberOfSteps()
        }
        guard shouldUpdateMarker else { return }
        // update marker position by using sequencer current time
        if clear {
            // Remove marker
            markerIndex = 0
            unhighlightRow(markerIndex)
            return
        }
        
        // Remove old marker and add new one
        unhighlightRow(markerIndex - 1)
        highlightRow(markerIndex)
    }
    
    func highlightRow(_ index: Int) {
        for i in 0..<collectionView.numberOfSections
        {
            let indexPath = IndexPath(row: index, section: i)
            guard let cell = collectionView.cellForItem(at: indexPath) as? SequencerCell else {
                continue
            }
            cell.isPlaying = true 
            cell.subviews.filter {
                $0.accessibilityIdentifier == "FillView"
                }.forEach {
                    $0.backgroundColor = .playOn
            }
        }
    }
    
    func unhighlightRow(_ index: Int) {
        var rowIndex = index
        // Clear last row if index reset
        if index < 0 {
            rowIndex = timeDivision.numberOfSteps() - 1
        }
        for i in 0..<collectionView.numberOfSections {
            let indexPath = IndexPath(row: rowIndex, section: i)
            guard let cell = collectionView.cellForItem(at: indexPath) as? SequencerCell else {
                continue
            }
            
            cell.isPlaying = false
            cell.subviews.filter {
                $0.accessibilityIdentifier == "FillView"
                }.forEach {
                    $0.backgroundColor = .sequencerCellPartialSelected
            }
        }
    }
    
    func deselectRow(_ index: Int) {
        var rowIndex = index
        // Clear last row if index reset
        if index < 0 {
            rowIndex = timeDivision.numberOfSteps() - 1
        }
        for i in 0..<collectionView.numberOfSections {
            let indexPath = IndexPath(row: rowIndex, section: i)
            deselectCell(indexPath)
        }
    }
    
    func deselectSection(_ index: Int) {
        var sectionIndex = index
        // Clear last row if index reset
        if index < 0 {
            sectionIndex = timeDivision.numberOfSteps() - 1
        }
        for i in 0..<collectionView.numberOfItems(inSection: sectionIndex) {
            let indexPath = IndexPath(row: i, section: sectionIndex)
            deselectCell(indexPath)
        }
    }
    
    func deselectCells() {
        collectionView.indexPathsForVisibleItems.forEach { deselectCell($0) }
        clearPartialFillCells()
    }
    
    func selectCell(_ indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SequencerCell else { return }
        cell.isEnabled = true
    }
    
    func deselectCell(_ indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SequencerCell else { return }
        cell.isEnabled = false
    }
    
    // TODO handle partial filling also handling its playstate UI
    func partialFillCell(_ indexPath: PartialIndexPath) {
        let path = IndexPath(row: Int(floor(indexPath.row)), section: indexPath.section)
        guard let cell = collectionView.cellForItem(at: path) else {
            return
        }
        
        let fillView = UIView()
        fillView.translatesAutoresizingMaskIntoConstraints = false
        fillView.backgroundColor = .sequencerCellPartialSelected
        fillView.accessibilityIdentifier = "FillView"
        cell.addSubview(fillView)
        NSLayoutConstraint.activate([
            fillView.topAnchor.constraint(equalTo: cell.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
            fillView.leftAnchor.constraint(equalTo: cell.leftAnchor),
            fillView.widthAnchor.constraint(equalTo: cell.widthAnchor, multiplier: 0.34)
            ])
    }
    
    func clearPartialFillCells() {
        for cell in collectionView.visibleCells {
            cell.subviews.filter{
                $0.accessibilityIdentifier == "FillView"
                }.forEach {
                    $0.removeFromSuperview()
            }
        }
    }
    
    // Update the collection view UI to match EventSequence state
    private func updateCollectionViewEventState() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        let events = AudioEngine.shared.sequencer.events
        deselectCells()
        
        let indexPaths = events.indexPathsFor(timeDivision: timeDivision)
        for indexPath in indexPaths {
            if let path = indexPath as? IndexPath {
                selectCell(path)
            } else {
                partialFillCell(indexPath as! PartialIndexPath)
            }
        }
    }    
}

extension SequencerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeDivision.numberOfSteps()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Number of samples in sequencer
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SequencerCell", for: indexPath) as! SequencerCell
        cell.backgroundColor = .whitePurple
        if indexPath.row > 0 {
            cell.shouldHideNote = true
        } else {
            cell.shouldHideNote = false
        }
        return cell
    }
}

extension SequencerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SequencerCell
        if cell.isEnabled {
            // Deselect
            cell.isEnabled = false
            AudioEngine.shared.sequencer.removeSequenceItem(indexPath: indexPath, stepSize: Float(timeDivision.numberOfSteps()) / 4.0)
        } else {
            // Select
            cell.isEnabled = true
            AudioEngine.shared.sequencer.addSequenceItem(indexPath: indexPath, stepSize: Float(timeDivision.numberOfSteps()) / 4.0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / CGFloat(timeDivision.numberOfSteps())
        let height = collectionView.frame.height / CGFloat(4)
        return CGSize(width: width, height: height)
    }
}

extension SequencerView: AudioEngineDelegate {
    func didUpdatePlaying(_ isPlaying: Bool) {
        self.isPlaying = isPlaying
    }
}
