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
    @IBOutlet weak var seekSlider: UISlider!
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

        seekSlider.backgroundColor = .clear        
        player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishTutorial), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.play()
        Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSliderPosition), userInfo: nil, repeats: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            seekSlider.maximumValue = Float(player?.currentItem?.duration.seconds ?? 0)
            seekSlider.minimumValue = 0
            seekSlider.value = Float(player?.currentItem?.currentTime().seconds ?? 0)
            view.bringSubview(toFront: seekSlider)
            
            seekSlider.alpha = 1
            UIView.animate(withDuration: 5, animations: {
                self.seekSlider.alpha = 0.2
            })
        }
    }
    
    @IBAction func seekValueChanged(_ sender: Any) {
        seekSlider.alpha = 1

        let slider = sender as! UISlider
        let time = CMTime(seconds: Double(slider.value), preferredTimescale: 1)
        player?.seek(to: time, completionHandler: { _ in
            UIView.animate(withDuration: 2, animations: {
                self.seekSlider.alpha = 0.2
            })
        })
    }
    
    @IBAction func didTapSlider(_ sender: Any) {
        self.seekSlider.alpha = 1
        UIView.animate(withDuration: 2, animations: {
            self.seekSlider.alpha = 0.2
        })
    }
    
    @objc func updateSliderPosition() {
        seekSlider.value = Float(player?.currentItem?.currentTime().seconds ?? 0)
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

