//
//  SequencerView.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 12/20/17.
//  Copyright © 2017 Joshua Escribano. All rights reserved.
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

protocol SequencerViewDelegate {
    func clearSequencerView(row: Int?)
    func didChangePlaying(_ isPlaying: Bool)
}

class SequencerView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var recordToggleButton: RecordToggleButton!
    @IBOutlet weak var tapTempoButton: TapTempoButton!
    
    private var timeDivision: TimeDivision = .eighth
    private let numberOfSamples = 4
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
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

        // Setup collection view
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SequencerCollectionView")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.layer.cornerRadius = 5

        recordToggleButton.delegate = self
        AudioEngine.shared.sequencer.viewDelegate = self
        
        updateAudioUI()
    }
    
    func updateAudioUI() {
        recordToggleButton.isOn = AudioEngine.shared.shouldRecord
        recordToggleButton.isPlaying = AudioEngine.shared.isPlaying
        tapTempoButton.currentTempo = AudioEngine.shared.sequencer.tempo
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update CollectionViewCell ItemSize if the Pane changes
        collectionView.collectionViewLayout.invalidateLayout()
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
            guard let cell = collectionView.cellForItem(at: indexPath) else {
                continue
            }
            cell.backgroundColor = .playOn
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
            guard let cell = collectionView.cellForItem(at: indexPath) else {
                continue
            }
            
            if cell.tag == 1 {
                cell.backgroundColor = .sequencerCellSelected
            } else {
                cell.backgroundColor = .sequencerCell
            }
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
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.tag = 1
        cell?.backgroundColor = .sequencerCellSelected
    }
    
    func deselectCell(_ indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.tag = 0
        cell?.backgroundColor = .sequencerCell
    }
    
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
}

extension SequencerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeDivision.numberOfSteps()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Number of samples in sequencer
        return numberOfSamples
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SequencerCollectionView", for: indexPath)
        cell.backgroundColor = .sequencerCell
        cell.layer.borderColor = UIColor.sequencerCellBorder.cgColor
        cell.layer.borderWidth = 2
        return cell
    }
}


// TODO How to keep state of sequence events to update collection view when time division changes
extension SequencerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if cell?.tag == 1 {
            // Deselect
            cell?.backgroundColor = .sequencerCell
            cell?.tag = 0
            AudioEngine.shared.sequencer.removeSequenceItem(indexPath: indexPath, stepSize: Float(timeDivision.numberOfSteps()) / 4.0)
        } else {
            // Select
            cell?.backgroundColor = .sequencerCellSelected
            cell?.tag = 1
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
        let height = collectionView.frame.height / CGFloat(numberOfSamples)
        return CGSize(width: width, height: height)
    }
}

extension SequencerView: SequencerViewDelegate {
    func didChangePlaying(_ isPlaying: Bool) {
        self.isPlaying = isPlaying
    }
    
    func clearSequencerView(row: Int? = nil) {
        if let r = row {
            deselectRow(r)
            return
        }
        
        for i in 0..<collectionView.numberOfSections {
            deselectSection(i)
        }
        
        clearPartialFillCells()
    }
}

extension SequencerView: CarouselViewDelegate {
    func willPresentView() {
        updateAudioUI()
    }
}

extension SequencerView: ToggleButtonDelegate {
    func didChangeValue(_ isOn: Bool) {
        AudioEngine.shared.shouldRecord = isOn
    }
    
    func didTap(sender: UITapGestureRecognizer) {
        AudioEngine.shared.toggleIsPlaying()
    }
}
