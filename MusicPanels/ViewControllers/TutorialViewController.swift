//
//  TutorialViewController.swift
//  MusicPanels
//
//  Created by Joshua Escribano on 3/31/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class TutorialViewController: UIViewController {
    let safeAreaView = UIView()
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(safeAreaView)
        NSLayoutConstraint.activate([
            safeAreaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            safeAreaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            safeAreaView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            safeAreaView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
            ])
        safeAreaView.frame = view.bounds
        startTutorialVideo()
    }
    
    func startTutorialVideo() {
        let video = Bundle.main.path(forResource: "TutorialVideo", ofType: "mp4")!
        let url = URL(fileURLWithPath: video)
        player = AVPlayer(url: url)
        let layer = AVPlayerLayer(player: player)
        layer.frame = safeAreaView.bounds
        layer.videoGravity =  .resizeAspect
        safeAreaView.layer.addSublayer(layer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishTutorial), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:         player?.currentItem)

        player?.play()
    }
    
    @objc func didFinishTutorial() {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func didDismiss(_ sender: Any) {
        player?.pause()
        player = nil
        dismiss(animated: false, completion: nil)
    }
}

