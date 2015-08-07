//
//  parkingDate.swift
//  stopTest
//
//  Created by Laibit on 2015/7/28.
//  Copyright (c) 2015年 Laibit. All rights reserved.
//

import UIKit

class parkingData: NSObject {
    private var parking : NSArray = NSArray()
    private let parkingURL: NSURL = NSURL(string: "http://localhost:8888/parking.php")!
    
    override init() {
        super.init()
        getMovieDataFromArrar()
    }
    
    //for model
    func getMovieDataFromArrar() ->NSArray{
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
            //把你data的那一行寫到這裡
            let data = NSData(contentsOfURL: self.parkingURL, options: NSDataReadingOptions.DataReadingUncached, error: nil)
            
            dispatch_async(dispatch_get_main_queue()) {
                //reload ui here! 或是做你拿到資料後想做的處理
                let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String: String]
                if (json != nil){
                    self.parking = NSArray(array: json as! NSArray)
                }
                
            }
            
        }
        
        /*
        let data = NSData(contentsOfURL: parkingURL, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
                
        parking = NSArray(array: json as! NSArray)
        */
        return parking
    }
    
    func getParkList()->NSArray{
        var list : [MainData] = Array()
        
        for result in parking{
            var mainData = MainData()
            mainData.title = result.objectForKey("parking_name") as! String
            mainData.addressP = result.objectForKey("parking_address") as! String
            mainData.toll_car = result.objectForKey("toll_car") as! String
            //mainData.lattitude = result.objectForKey("lattiude") as! Double
            //mainData.longitude = result.objectForKey("longitude") as! Double
            
            list.append(mainData)
        }
        
        return list
    }
    
}
