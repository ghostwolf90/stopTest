//
//  CustomTableViewCell.swift
//  stopTest
//
//  Created by Laibit on 2015/7/31.
//  Copyright (c) 2015年 Laibit. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var parkingNameLable: UILabel!
    @IBOutlet weak var parkingAddress: UILabel!
    @IBOutlet weak var tollLable: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(mapData: MainData) {
        parkingNameLable.text = mapData.title
        parkingAddress.text = mapData.addressP
        tollLable.text = mapData.toll_car        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
