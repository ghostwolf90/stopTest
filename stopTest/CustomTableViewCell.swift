//
//  CustomTableViewCell.swift
//  stopTest
//
//  Created by Laibit on 2015/7/31.
//  Copyright (c) 2015年 Laibit. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var parkingNameLable: UILabel!
    @IBOutlet weak var parkingAddress: UILabel!
    @IBOutlet weak var tollLable: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
