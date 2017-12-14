//
//  LeadboardTableViewCell.swift
//  SaveTheDot
//
//  Created by 改车吧 on 2017/12/11.
//  Copyright © 2017年 Jake Lin. All rights reserved.
//

import UIKit

class LeadboardTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var timeNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code


    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
