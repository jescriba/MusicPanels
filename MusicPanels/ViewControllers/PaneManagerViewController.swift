//
//  ViewController.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 12/19/17.
//  Copyright © 2017 Joshua Escribano. All rights reserved.
//

import UIKit
import MessageUI

// TODO refactor panetype/configuration since they might not be used anymore
enum PaneType {
    case sequencer, keyboard, adsr
}

class PaneConfiguration {
    var top: PaneType
    var bottom: PaneType
    
    init(top: PaneType, bottom: PaneType) {
        self.top = top
        self.bottom = bottom
    }
}

protocol PaneScrollDelegate {
    func didPanOnBorder(sender: UIPanGestureRecognizer)
}

class PaneManagerViewController: UIViewController {
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var topBorderConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomCarouselView: CarouselView!
    @IBOutlet weak var topCarouselView: CarouselView!
    @IBOutlet weak var playheadView: UIView!
    @IBOutlet weak var playtrackView: UIView!
    @IBOutlet weak var playheadConstraint: NSLayoutConstraint!
    
    var playheadPositionTimer: Timer?
    var paneConfiguration = PaneConfiguration(top: .sequencer, bottom: .keyboard)
    var maxBottomOffset: CGFloat = 80.0
    var maxTopOffset: CGFloat = 60.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(didDragOnBorder(sender:)))
        borderView.addGestureRecognizer(recognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(sender:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        borderView.addGestureRecognizer(doubleTapRecognizer)
        
        borderView.backgroundColor = UIColor.paneBorder
        playheadView.layer.cornerRadius = 10
        // Setup playhead UI based on AudioEngine state
        AudioEngine.shared.delegate = self
        updatePlayheadAndTrack()
        
        // Couldn't add screen edge recognizer in storyboard???
        // wtf.. needed to add separate recognizers for both edges
        let rightEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(didRightEdgePan))
        rightEdgeRecognizer.edges = .right
        view.addGestureRecognizer(rightEdgeRecognizer)
        
        let leftEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(didLeftEdgePan))
        leftEdgeRecognizer.edges = .left
        view.addGestureRecognizer(leftEdgeRecognizer)
        
        CatalogManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: pain trying to figure out why scrollview not currently
        // offset in CommonInit()
        topCarouselView.currentIndex = topCarouselView.startIndex
        bottomCarouselView.currentIndex = bottomCarouselView.startIndex
        
        // Check for intro experience
        if !TutorialManager.hasSeenTutorial() {
            presentHelpNavigationViewController()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Incrementally update the playhead position
    @objc func updatePlayheadPosition() {
        playheadConstraint.constant = playtrackView.bounds.width * CGFloat(AudioEngine.shared.trackTimeRatio) - playheadView.bounds.width / 2
    }
    
    // Update playhead and track ui configuration once audio state changes
    func updatePlayheadAndTrack() {
        playheadConstraint.constant = playtrackView.bounds.width * CGFloat(AudioEngine.shared.trackTimeRatio)
        if AudioEngine.shared.isPlaying {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: [], animations: {
                self.playtrackView.alpha = 0.2
            }, completion: nil)
            // Start tracking playhead position
            playheadPositionTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updatePlayheadPosition), userInfo: nil, repeats: true)
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
                self.playtrackView.alpha = 0
            }, completion: nil)
            playheadView.layer.removeAllAnimations()
            // Stop tracking playhead position
            playheadPositionTimer?.invalidate()
        }
        
        if AudioEngine.shared.isRecording {
            // Playing and recording
            UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse, .curveEaseOut], animations: {
                self.playheadView.alpha = 0
            }, completion: { (_) in
                self.playheadView.alpha = 1
            })
        }
        
        if AudioEngine.shared.isPlaying &&
            !AudioEngine.shared.shouldRecord {
            // Ensure playhead is no longer animated
            playheadView.layer.removeAllAnimations()
        }
    }
    
    func presentHelpNavigationViewController() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "HelpNavigationViewController") as! HelpNavigationViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    @objc func didDoubleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // Present help/navigation screen
            presentHelpNavigationViewController()
        }
    }
    
    @objc func didRightEdgePan(sender: UIScreenEdgePanGestureRecognizer) {
        let carouselView: CarouselView
        let notSelectedCarouselView: CarouselView
        if sender.location(in: view).y < borderView.frame.minY {
            carouselView = topCarouselView
            notSelectedCarouselView = bottomCarouselView
        } else {
            carouselView = bottomCarouselView
            notSelectedCarouselView = topCarouselView
        }
        if sender.state == .changed {
            carouselView.didRightEdgePan(xLocation: sender.location(in: nil).x)
        }
        
        guard sender.state == .ended else { return }
        if sender.velocity(in: nil).x < 0 {
            // Completely open right topView item
            carouselView.openRightView()
        } else {
            // Completely close right topView item
            carouselView.closeRightView()
        }
        notSelectedCarouselView.centerView()
    }
    
    @objc func didLeftEdgePan(sender: UIScreenEdgePanGestureRecognizer) {
        let carouselView: CarouselView
        let notSelectedCarouselView: CarouselView
        if sender.location(in: view).y < borderView.frame.minY {
            carouselView = topCarouselView
            notSelectedCarouselView = bottomCarouselView
        } else {
            carouselView = bottomCarouselView
            notSelectedCarouselView = topCarouselView
        }
        if sender.state == .changed {
            // Update positioning of topView
            carouselView.didLeftEdgePan(xLocation: sender.location(in: nil).x)
        }
        
        guard sender.state == .ended else { return }
        if sender.velocity(in: nil).x > 0 {
            // Completely open left topView item
            carouselView.openLeftView()
        } else {
            // Completely close left topView item
            carouselView.closeLeftView()
        }
        notSelectedCarouselView.centerView()
    }
    
    @objc func didDragOnBorder(sender: UIPanGestureRecognizer) {
        let y = sender.location(in: nil).y
        if y > view.frame.height - maxBottomOffset || y < maxTopOffset {
            return
        }
        
        let velocity = sender.velocity(in: nil)
        if abs(velocity.y) > abs(velocity.x) {
            topBorderConstraint.constant = y
        } else {
            for delegate in topCarouselView.paneScrollDelegates {
                delegate.didPanOnBorder(sender: sender)
            }
            for delegate in bottomCarouselView.paneScrollDelegates {
                delegate.didPanOnBorder(sender: sender)
            }
        }
        if sender.state == .ended {
            borderView.backgroundColor = UIColor.paneBorder
        } else {
            borderView.backgroundColor = UIColor.paneBorderSelected
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            AudioEngine.shared.sequencer.clear()
        }
    }

}

extension PaneManagerViewController: CatalogManagerDelegate {
    func didExport(song: Song, filePath: String) {
        guard let fileName = song.fileName else { return }
        guard let songData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return }
        
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        messageVC.body = "Check out my song made with MusicPanels";
        messageVC.addAttachmentData(songData, typeIdentifier: "audio/aiff", filename: "\(fileName).aif")
        messageVC.recipients = [""]
        messageVC.messageComposeDelegate = self;
        
        present(messageVC, animated: true, completion: nil)
    }
}

extension PaneManagerViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            dismiss(animated: true, completion: nil)
        case .failed:
            dismiss(animated: true, completion: nil)
        case .sent:
            dismiss(animated: true, completion: nil)
        }
    }
}

extension PaneManagerViewController: AudioEngineDelegate {
    func didUpdateIsPlaying(_ isPlaying: Bool) {
        updatePlayheadAndTrack()
    }
}
