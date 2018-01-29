//
//  RecorderDetailTableViewCell.swift
//  HelloRecorder
//
//  Created by 胡靜諭 on 2018/1/30.
//  Copyright © 2018年 胡靜諭. All rights reserved.
//

import UIKit

class RecorderDetailTableViewCell: UITableViewCell {
    
    @IBOutlet var label: UILabel!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = UIView(frame: self.frame)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 4
        self.selectedBackgroundView = view
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
