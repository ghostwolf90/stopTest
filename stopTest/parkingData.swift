//
//  parkingDate.swift
//  stopTest
//
//  Created by Laibit on 2015/7/28.
//  Copyright (c) 2015年 Laibit. All rights reserved.
//
/* <註1>: 可以改成 Swift 的宣告方式
[AnyObject] === Array<AnyObject>-> 代表是一種Array
[String:AnyObject] === Dictionary<String, AnyObject> -> 代表Dictionary

<註2>: [String:String] 代表的是 (Key只能是String型態, Value只能是String型態的) Dictionary，而不是Array
所以 as? [String:String]代表是要轉型成字典，但你的JSON應該是Array，所以轉型失敗，當然會nil，在這裡我會建議你不要做任何轉型

<註3>:
你可以等到要判斷data的時候，再進行轉型，並驗驗是否正確

<註4>:
處理轉型失敗後的情況，代表json裡面解析後不是Array，那就可以進行其他型別的轉型
*/

import UIKit

class parkingData: NSObject {
    private var parking = [AnyObject]() /*<註1>代表宣告一個存放任意型別物件的Array*/
    private let parkingURL: NSURL = NSURL(string: "http://localhost:8888/parking.php")!
    var list : [MainData] = Array()
    
    override init() {
        super.init()
        
        getParking( { (parkings:[AnyObject]) -> Void in
            for parking in parkings {
                let mainData = MainData()
                mainData.title = parking.objectForKey("parking_name") as! String
                mainData.addressP = parking.objectForKey("parking_address") as! String
                mainData.toll_car = parking.objectForKey("toll_car") as! String
                
                self.list.append(mainData)
            }
        })
    }
    
    //請外部傳一個closure，讓你的程式在完成的時候可以告知他
    func getParking(completion: (parkings:[AnyObject]) -> Void){
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let data = try? NSData(contentsOfURL: self.parkingURL, options: NSDataReadingOptions.DataReadingUncached)
            let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            if let nonull_json = json as? [AnyObject] {
                self.parking = nonull_json /*NSArray(array: json as! NSArray)*/
            }else{
                /*<註4>*/
            }
            
            dispatch_async(dispatch_get_main_queue()){
                completion(parkings: self.parking)
                
            }
        }
    }
    
    //for model
    func getMovieDataFromArrar() -> [AnyObject] {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
        //把你data的那一行寫到這裡
        let data = try? NSData(contentsOfURL: self.parkingURL, options: NSDataReadingOptions.DataReadingUncached)
        dispatch_async(dispatch_get_main_queue()) {
            //reload ui here! 或是做你拿到資料後想做的處理
            let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)/*<註2>as? [String: String]*/
                
            /*<註3>: 可以寫成Swift的 if let語法就可以了*/
            /*if (json != nil){
            self.parking = /*NSArray(array: json as! NSArray)*/
            }*/
                
            if let nonull_json = json as? [AnyObject] {
                self.parking = nonull_json /*NSArray(array: json as! NSArray)*/
            }else{
                /*<註4>*/
            }
                
            }
        }
        return parking
    }
    
    func getParkList(completion : (parkings:[AnyObject]) -> Void){
        var list : [MainData] = Array()
        
        for result in parking{
            let mainData = MainData()
            mainData.title = result.objectForKey("parking_name") as! String
            mainData.addressP = result.objectForKey("parking_address") as! String
            mainData.toll_car = result.objectForKey("toll_car") as! String
            //mainData.lattitude = result.objectForKey("lattiude") as! Double
            //mainData.longitude = result.objectForKey("longitude") as! Double
            
            list.append(mainData)
        }
        
        completion(parkings: self.list)
    }
    
}
