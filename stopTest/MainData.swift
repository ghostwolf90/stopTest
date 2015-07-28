//
//  MainData.swift
//  stopTest
//
//  Created by Laibit on 2015/7/28.
//  Copyright (c) 2015年 Laibit. All rights reserved.
//

import UIKit

class MainData: NSObject {
    var descriptionFilterHtml : String
    var showTimeList : NSArray
    var address: String
    var title: String
    var name : String
    var time : String
    var location : String
    var lattitude : Double
    var longitude : Double
    
    override init(){
        descriptionFilterHtml   = ""
        showTimeList            = NSArray()
        address                 = ""
        title                   = ""
        name                    = ""
        time                    = ""
        location                = ""
        lattitude               = 0.0
        longitude               = 0.0
        
    }
    
}