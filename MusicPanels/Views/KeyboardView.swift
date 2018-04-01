//
//  KeyboardView.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 12/19/17.
//  Copyright © 2017 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit
import AudioKit
import AudioKitUI

class KeyboardView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var akKeyboardView: AKKeyboardView!
    var delegate: PaneScrollDelegate?
    private var currentXOffset: CGFloat!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
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
        
        akKeyboardView.firstOctave = 3
        akKeyboardView.polyphonicMode = true
        akKeyboardView.octaveCount = 3
        akKeyboardView.keyOnColor = UIColor.keyOn
        
        // Set keyboard to handle audio + AKKeyboardDelegate methods
        akKeyboardView.delegate = AudioEngine.shared.keyboard
        
        currentXOffset = 0
    }
}

extension KeyboardView: PaneScrollDelegate {
    @objc func didPanOnBorder(sender: UIPanGestureRecognizer) {
        let xTranslation = sender.translation(in: nil).x
        // -1 multipler for swipe scroll
        let newXContentOffset = currentXOffset - xTranslation
        var offsetPoint = CGPoint(x: newXContentOffset, y: 0)
        // TODO Reset offset to center and update the akKeyboardView's first octave
        // TODO Visual indicator that the octave is changing. Maybe a temporary C4 etc... label indicator?
        if newXContentOffset < -1 * frame.width {
            if akKeyboardView.firstOctave > 2 {
                akKeyboardView.firstOctave = akKeyboardView.firstOctave - 1
                offsetPoint.x = 0 // Recenter mimicing 'infinite scroll'
            } else {
                offsetPoint.x = -1 * frame.width
            }
        }
        if newXContentOffset > frame.width {
            // TODO Guessing lower firstOctave 0 limit and upper firstOctave 6 limit
            if akKeyboardView.firstOctave < 5 {
                akKeyboardView.firstOctave = akKeyboardView.firstOctave + 1
                offsetPoint.x = 0 // Recenter mimicing 'infinite scroll'
            } else {
                offsetPoint.x = frame.width
            }
        }
        scrollView.setContentOffset(offsetPoint, animated: false)
        if sender.state == .ended {
            currentXOffset = scrollView.contentOffset.x
        }
    }
}
