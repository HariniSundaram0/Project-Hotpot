//
//  RadioModeViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 8/9/22.
//

import UIKit

class RadioModeViewController: HomeViewController {
    //ensures correct algorithm is being used
    override func viewDidAppear(_ animated: Bool) {
        NSLog("entering Radio Mode")
        super.exploreMode = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            super.exploreMode = true
        }
    }
}
