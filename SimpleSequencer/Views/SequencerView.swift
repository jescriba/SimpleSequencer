//
//  SequencerView.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 4/28/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

/**
    TimeDivison representing number of events in a measure.
 
    For example: 4 notes a measure is .quarter, 8 notes a measure is .eighth - this currently assumes 4/4 time signature
*/
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

/// Delegate for handling note picker UI and events
class PickerDelegate: NSObject {
    var hidePicker: ((IndexPath?) -> ())?
}

/// View corresponding to sequencer collection view and note picker
class SequencerView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pickerCollectionView: UICollectionView!
    @IBOutlet weak var pickerWidth: NSLayoutConstraint!
    
    @IBOutlet weak var visualEffectContainerView: UIView!
    
    fileprivate let pickerDelegate = PickerDelegate()
    fileprivate var timeDivision: TimeDivision = .eighth {
        didSet {
            pickerWidth.constant = collectionView.bounds.width / CGFloat(timeDivision.numberOfSteps())
            pickerCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    // Handle which notes are active on screen
    fileprivate var notes: [Note] = [
                                      Note(key: "G", octave: 3, velocity: 60),
                                      Note(key: "B", octave: 3, velocity: 60),
                                      Note(key: "D", octave: 3, velocity: 60),
                                      Note(key: "F", octave: 3, velocity: 60)
                                    ]
    private var activeSelectingPath: IndexPath!
    private var isAnimatingPicker = false
    private var shouldUpdateMarker = false
    private var markerIndex = 0 {
        didSet {
            shouldUpdateMarker = true
        }
    }
    /// Timer for polling playhead UI positioning
    private var currentBeatTimer = Timer()
    /// Indicate playing state. Will set beat timer for playhead
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
    
    /**
        Common initializer for sequencer view UI and initial state
    */
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
        
        pickerDelegate.hidePicker = hidePicker
        pickerCollectionView.register(SequencerCell.self, forCellWithReuseIdentifier: "SequencerCell")
        pickerCollectionView.dataSource = pickerDelegate
        pickerCollectionView.delegate = pickerDelegate
        pickerCollectionView.layer.cornerRadius = 5
        pickerCollectionView.isHidden = true
        visualEffectContainerView.isHidden = true
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        effectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectContainerView.backgroundColor = .clear
        visualEffectContainerView.alpha = 0.8
        visualEffectContainerView.insertSubview(effectView, at: 0)
        NSLayoutConstraint.activate([
            effectView.leadingAnchor.constraint(equalTo: visualEffectContainerView.leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: visualEffectContainerView.trailingAnchor),
            effectView.topAnchor.constraint(equalTo: visualEffectContainerView.topAnchor),
            effectView.bottomAnchor.constraint(equalTo: visualEffectContainerView.bottomAnchor),
            ])
        pickerWidth.constant = collectionView.bounds.width / CGFloat(timeDivision.numberOfSteps())
        
        AudioEngine.shared.sequencer.clearHandler = clear
    }
    
    /**
        Pinch recognizer for changing the time division
    */
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
    
    /**
        Update UI for the sequencer playhead positioning
        - Parameter clear: Optional bool to clear the playhead UI. Used when sequencer is stopped. Default value is false
    */
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
    
    /**
        Highlight row of collection view
        - Parameter index: Integer for row in collection view to highlight
    */
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
                    $0.backgroundColor = .black
            }
        }
    }
    
     /**
         Unhighlight row of collection view
         - Parameter index: Integer for row in collection view to unhighlight
     */
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
                    $0.backgroundColor = .solidPurple2
            }
        }
    }
    
    /**
        Deselect row. Turns all sequencer cells UI to disabled state
        - Parameter index: Integer for index of row to deselect
    */
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
    
    /**
        Deselects all the cells. Puts the cells in the disabled state.
    */
    func deselectCells() {
        collectionView.indexPathsForVisibleItems.forEach { deselectCell($0) }
        clearPartialFillCells()
    }
    
    /**
        Select cell by putting sequencer cell into 'enabled' state
        - Parameter indexPath: IndexPath of the collection view cell to enable
    */
    func selectCell(_ indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SequencerCell else { return }
        cell.isEnabled = true
    }
    
     /**
         Deselect cell by putting sequencer cell into 'disabled' state
         - Parameter indexPath: IndexPath of the collection view cell to disable
     */
    func deselectCell(_ indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SequencerCell else { return }
        cell.isEnabled = false
    }
    
    /**
        Partially fill cell. This creates a UI representation of a 'partial' event occuring in the sequencer cell. For example: an eighth note on a quarter note grid will partially fill the cell corresponding to the nearest quarter note.
        - Parameter indexPath: The PartialIndexPath (an indexPath with double values for row and section) representing the cell to partially fill
    */
    func partialFillCell(_ indexPath: PartialIndexPath) {
        let path = IndexPath(row: Int(floor(indexPath.row)), section: indexPath.section)
        guard let cell = collectionView.cellForItem(at: path) as? SequencerCell else {
            return
        }
        
        let fillView = UIView()
        fillView.translatesAutoresizingMaskIntoConstraints = false
        fillView.backgroundColor = .solidPurple2
        fillView.accessibilityIdentifier = "FillView"
        fillView.layer.cornerRadius = 10
        cell.addSubview(fillView)
        NSLayoutConstraint.activate([
            fillView.topAnchor.constraint(equalTo: cell.mainView.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: cell.mainView.bottomAnchor),
            fillView.leftAnchor.constraint(equalTo: cell.mainView.leftAnchor),
            fillView.widthAnchor.constraint(equalTo: cell.mainView.widthAnchor, multiplier: 0.34)
            ])
    }
    
    /**
        Clear all partially filled cells
    */
    func clearPartialFillCells() {
        for cell in collectionView.visibleCells {
            cell.subviews.filter{
                $0.accessibilityIdentifier == "FillView"
                }.forEach {
                    $0.removeFromSuperview()
            }
        }
    }
    
    /**
        Show the sequencer note picker view according to the sender.
        - Parameter sender: UILongPressGestureRecognizer corresponding to an active sequencer note visible on screen
    */
    @objc func showPicker(sender: UILongPressGestureRecognizer) {
        guard let cell = sender.view as? SequencerCell,
              let section = Note.all.index(where: { (note) -> Bool in
            note.key == cell.note.key && note.octave == cell.note.octave
        }),
            let path = collectionView.indexPath(for: cell) else { return }
        activeSelectingPath = path
        let pickerPath = IndexPath(row: 0, section: section)
        pickerCollectionView.scrollToItem(at: pickerPath, at: .centeredVertically, animated: false)
        pickerCollectionView.isHidden = false
        visualEffectContainerView.isHidden = false
        guard let pickerCell = pickerCollectionView.cellForItem(at: pickerPath) else { return }
        animatePicker(cell: pickerCell)
    }
    
    /**
        Animates the sequencer cell while picking a new note
        - Parameter cell: UICollectionViewCell view to animate scale
    */
    func animatePicker(cell: UICollectionViewCell) {
        guard !isAnimatingPicker else { return }
        isAnimatingPicker = true
        cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1, options: [], animations: {
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { [weak self] _ in
            self?.isAnimatingPicker = false
        })
    }
    
    /**
        Hide note picker view
        - Parameter indexPath: Optional IndexPath for hiding and selecting the new sequencer note for that row
    */
    func hidePicker(indexPath: IndexPath? = nil) {
        pickerCollectionView.isHidden = true
        visualEffectContainerView.isHidden = true
        
        guard let path = indexPath,
              let cell = pickerCollectionView.cellForItem(at: path) as? SequencerCell else { return }
        
        // Update sequencer row based on the picker cell's note
        notes[activeSelectingPath.section] = cell.note
        collectionView.reloadData()
    }
    
    /**
        Updates collection view event state. Used for transfering UI event state from one 'timeDivision' (i.e. quarter, eighth, etc..) to another denomination
    */
    private func updateCollectionViewEventState() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        let events = AudioEngine.shared.sequencer.events
        deselectCells()
        
        let visibleTracks = notes.map { $0.keyNumber() }
        let indexPaths = events.indexPathsFor(timeDivision: timeDivision, visibleTracks: visibleTracks)
        for indexPath in indexPaths {
            if let path = indexPath as? IndexPath {
                selectCell(path)
            } else {
                partialFillCell(indexPath as! PartialIndexPath)
            }
        }
    }
    
    /**
        Clear the sequencer UI for the specified track or all tracks.
        - Parameter clear: Int for track UI to clear or all tracks if none specified
    */
    func clear(_ track: Int? = nil) {
        guard let t = track else {
            // Clear all the tracks UI
            deselectCells()
            return
        }
        
        // Clear the specific track UI
        deselectRow(t)
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
        let note = notes[indexPath.section]
        cell.note = note
        cell.backgroundColor = .whitePurple
        if indexPath.row > 0 {
            cell.shouldHideNote = true
        } else {
            cell.shouldHideNote = false
            let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(showPicker(sender:)))
            cell.addGestureRecognizer(recognizer)
        }
        
        cell.isEnabled = EventHelper.isEnabled(note: note,
                                               timeDivision: timeDivision,
                                               row: indexPath.row)
        
        // TODO @joshua partial fill handling
        return cell
    }
}

extension SequencerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SequencerCell
        if cell.isEnabled {
            // Deselect
            cell.isEnabled = false
            AudioEngine.shared.sequencer.removeSequenceItem(note: cell.note, indexPath: indexPath, stepSize: Float(timeDivision.numberOfSteps()) / 4.0)
        } else {
            // Select
            cell.isEnabled = true
            AudioEngine.shared.sequencer.addSequenceItem(note: cell.note, indexPath: indexPath, stepSize: Float(timeDivision.numberOfSteps()) / 4.0)
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

extension PickerDelegate: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Number of samples in sequencer
        return Note.all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SequencerCell", for: indexPath) as! SequencerCell
        cell.note = Note.all[indexPath.section]
        cell.backgroundColor = .whitePurple
        cell.shouldHideNote = false
        return cell
    }
}

extension PickerDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hidePicker?(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width 
        let height = collectionView.frame.height / CGFloat(4)
        return CGSize(width: width, height: height)
    }
}

extension SequencerView: AudioEngineDelegate {
    func didUpdatePlaying(_ isPlaying: Bool) {
        self.isPlaying = isPlaying
    }

    func didUpdateTempo(_ tempo: Double) {} 
}
