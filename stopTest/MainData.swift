//
//  MainData.swift
//  stopTest
//
//  Created by Laibit on 2015/7/28.
//  Copyright (c) 2015年 Laibit. All rights reserved.
//

import UIKit

struct MainData {
    var title = ""
    var addressP = ""
    var toll_car = ""
    var time = ""
    var lattitude: Double = 0.0
    var longitude: Double = 0.0
    
    init(addressP: String, title: String, toll_car: String, time: String, lattitude: Double, longitude: Double) {
        self.addressP = addressP
        self.title = title
        self.toll_car = toll_car
        self.time = time
        self.lattitude = lattitude
        self.longitude = longitude
    }
    
    init() {
        
    }
    
}
