//
//  ViewController.swift
//  FRCircleSlider
//
//  Created by johnny12000 on 07/10/2017.
//  Copyright (c) 2017 johnny12000. All rights reserved.
//

import UIKit
import FRCircleSlider

class ViewController: UIViewController {

    @IBOutlet var circleSlider: FRCircleSlider!

    @IBOutlet var value1: UILabel!
    @IBOutlet var value2: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        valueChanged(self)
    }

    @IBAction func valueChanged(_ sender: Any) {
        value1.text = "Value1: \(circleSlider.value1)"
        value2.text = "Value2: \(circleSlider.value2)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
