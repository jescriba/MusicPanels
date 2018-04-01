//
//  HelpNavigationController.swift
//  MusicPanels
//
//  Created by Joshua Escribano on 3/31/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit

class HelpNavigationViewController: UIViewController {
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var helpDetailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.frame
        view.addSubview(blurView)
        view.sendSubview(toBack: blurView)
        
        if TutorialManager.hasSeenTutorial() {
            helpDetailsLabel.isHidden = true
            getStartedButton.setTitle("Continue", for: .normal)
        }
    }
    
    @IBAction func didTapTutorial(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        present(vc, animated: false, completion: nil)
    }
    
    @IBAction func didDismiss(_ sender: Any) {
        // Update intro experience seen at least once
        TutorialManager.setHasSeenTutorial()
        dismiss(animated: true, completion: nil)
    }
}
