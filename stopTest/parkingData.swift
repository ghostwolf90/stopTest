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
    //private let parkingURL: NSURL = NSURL(string: "http://cloud.culture.tw/frontsite/trans/SearchShowAction.do?method=doFindTypeJ&category=8")!
    
    override init() {
        super.init()
        getMovieDataFromArrar()
    }
    
    //for model
    func getMovieDataFromArrar() ->NSArray{
        let data = NSData(contentsOfURL: parkingURL, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
        
        parking = NSArray(array: json as! NSArray)
        
        return parking
    }
    
    func getParkList()->NSArray{
        var list : [MainData] = Array()
        
        for result in parking{
            var mainData = MainData()
            let title = result.objectForKey("parking_name") as! NSString
            let address = result.objectForKey("parking_address") as! NSString
            
            //有資料才show
            mainData.title = title as String
            mainData.address = address as String
            
            list.append(mainData)
        }
        
        return list
    }
    
    
    
}
