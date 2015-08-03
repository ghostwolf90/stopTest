//
//  MainData.swift
//  stopTest
//
//  Created by Laibit on 2015/7/28.
//  Copyright (c) 2015年 Laibit. All rights reserved.
//

import UIKit

class MainData: NSObject {
    var title: String
    var addressP: String
    var toll_car : String
    var time : String
    var lattitude : Double
    var longitude : Double
    
    override init(){
        addressP                = ""
        title                   = ""
        toll_car                = ""
        time                    = ""
        lattitude               = 0.0
        longitude               = 0.0        
    }
    
}