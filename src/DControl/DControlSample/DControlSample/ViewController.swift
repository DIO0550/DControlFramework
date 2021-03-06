//
//  ViewController.swift
//  DControlSample
//
//  Created by DIO on 2019/11/26.
//  Copyright © 2019 DIO. All rights reserved.
//

import UIKit
import DControl

class ViewController: UIViewController {
    @IBOutlet weak var segmentedControl: DSegumentedControl!
    
    @IBAction func toucheUpButton(_ sender: Any) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segmentedControl.insertSegment(withTitle: "First", at: 0, animated: true)
        self.segmentedControl.insertSegment(withTitle: "Second", at: 1, animated: true)
        self.segmentedControl.insertSegment(withTitle: "Third", at: 2, animated: true)
        
        self.segmentedControl.selectedSegmentIndex = 0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBAction func selectSegment(_ sender: Any) {
        
    }
}

