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

class parkingData {
    private var parking = [String]() /*<註1>代表宣告一個存放任意型別物件的Array*/
    private let parkingURL: URL = URL(string: "http://localhost:8888/parking.php")!
    var list: [MainData] = Array()

    init() {
        getParking( completion: { (parkings: [String]) -> Void in
            for parking in parkings {
                let mainData = MainData()
//                mainData.title = parking["parking_name"] as! String
//                mainData.addressP = parking.object("parking_address") as! String
//                mainData.toll_car = parking.object("toll_car") as! String
                self.list.append(mainData)
            }
        })
    }
    
    //請外部傳一個closure，讓你的程式在完成的時候可以告知他
    func getParking(completion: @escaping ([String]) -> Void) {
        DispatchQueue.global(qos: .default).async {
            do {
                let data = try Data(contentsOf: self.parkingURL as URL)
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let parkings = jsonObject["someKey"] as? [String] {
                    DispatchQueue.main.async {
                        completion(parkings)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    
    //for model
    func getMovieDataFromArray(completion: @escaping ([String]) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            // 尝试获取数据
            do {
                let data = try Data(contentsOf: self.parkingURL)
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        // 假设您要从JSON中解析出字符串数组
                        let parsedData = jsonObject["yourKey"] as? [String] ?? []
                        completion(parsedData)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            } catch {
                print("Error: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    
    func getParkList(completion : (_ parkings: [MainData]) -> Void) {
        var list = [MainData]()
        
        for result in parking {
            let mainData = MainData()
//            mainData.title = result.object("parking_name") as! String
//            mainData.addressP = result.object("parking_address") as! String
//            mainData.toll_car = result.object("toll_car") as! String
            //mainData.lattitude = result.objectForKey("lattiude") as! Double
            //mainData.longitude = result.objectForKey("longitude") as! Double
            list.append(mainData)
        }
        completion(self.list)
    }
    
}
