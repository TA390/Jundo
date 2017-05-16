//
//  LaunchViewController.swift
//  Jundo
//
//  Created by TA on 29/04/2017.
//  Copyright © 2017 Splynter Inc. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        ai.center = view.center
        ai.center.y /= 2.0
        ai.hidesWhenStopped = false
        ai.startAnimating()
        view.addSubview(ai)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
