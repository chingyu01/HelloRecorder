//
//  ViewController.swift
//  HelloRecorder
//
//  Created by 胡靜諭 on 2018/1/28.
//  Copyright © 2018年 胡靜諭. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

    @IBOutlet var timeShowLabel: UILabel!
    
    @IBOutlet var RecordButton: UIButton!
    
    @IBOutlet var PlayButton: UIButton!
    
     @IBOutlet var StopButton: UIButton!
    
    var recorder:AVAUio
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
        
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func ShowRecorderButton(_ sender: UIButton) {
    }

}

