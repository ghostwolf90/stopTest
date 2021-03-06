//
//  ViewController.swift
//  stopTest
//
//  Created by Laibit on 2015/7/23.
//  Copyright (c) 2015年 Laibit. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    var location: CLLocationManager!
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var tableView:UITableView!
    
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var point:MKPointAnnotation!
    var c:CLLocation!
    let refreshControl = UIRefreshControl()
    var parkingList = [MainData](){
        didSet{
            //do something
            //update ui
            self.tableView.reloadData()
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seenError = false
        locationFixAchieved = false
        
        location = CLLocationManager()
        location.delegate = self
        //詢問是否要給APP有定位功能權限
        location.requestWhenInUseAuthorization()
        //開啟計算目前行動裝置所在位置的功能
        location.startUpdatingLocation()
        
        postToServerFunction { (parkings) -> Void in
            for parking in parkings {
                let mainData = MainData()
                mainData.title = parking.objectForKey("parking_name") as! String
                mainData.addressP = parking.objectForKey("parking_address") as! String
                mainData.toll_car = parking.objectForKey("toll_car") as! String
                
                self.parkingList.append(mainData)
//                //update ui
//                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        point = MKPointAnnotation()
        //point.coordinate = CLLocationCoordinate2DMake(c.coordinate.latitude, c.coordinate.longitude)
        point.coordinate = CLLocationCoordinate2DMake(24.136299, 120.66629)
        point.title = "台中市"
        point.subtitle = "所在位置"
        self.myMap.addAnnotation(point)
    
        //放大效果
        let track = CLLocationCoordinate2D(latitude: 24.136299, longitude: 120.66629)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        _ = MKCoordinateRegion(center: track, span: span)
        
        //self.myMap.centerCoordinate = CLLocationCoordinate2DMake(c.coordinate.latitude, c.coordinate.longitude)
        self.myMap.centerCoordinate = CLLocationCoordinate2DMake(24.136299, 120.66629)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Location Manager Delegate stuff
    // If failed
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        location.stopUpdatingLocation()
    
        /*
        if ((error) != nil) {
            if (seenError == false) {
                seenError = true
                print(error, terminator: "")
            }
        }*/
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        c = locationArray[0] as! CLLocation
        NSLog("緯度:%f, 精度:%f, 高度:%f", c.coordinate.latitude, c.coordinate.longitude, c.altitude)
    }
    
    //authorization status
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            var shouldIAllow = false
            
            switch status {
            case CLAuthorizationStatus.Restricted:
                locationStatus = "Restricted Access to location"
            case CLAuthorizationStatus.Denied:
                locationStatus = "User denied access to location"
            case CLAuthorizationStatus.NotDetermined:
                locationStatus = "Status not determined"
            default:
                locationStatus = "Allowed to location Access"
                shouldIAllow = true
            }
            NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
            if (shouldIAllow == true) {
                NSLog("Location to Allowed")
                // Start location services
                location.startUpdatingLocation()
            } else {
                NSLog("Denied access: \(location)")
            }
    }

    
    override func viewDidDisappear(animated: Bool) {
        //關閉計算目前行動裝置所在位置功能
        location.stopUpdatingLocation()
    }
    
    
    func postToServerFunction(completion: (parkings:[AnyObject]) -> Void){
        let USERNAME_S = "101"
        let PASSWD_S = "台中"
        
        //var post:NSString = "username=\(username)&password=\(passwd)"
        let post:NSString = "CITY_NO=\(USERNAME_S)&CITY_NAME=\(PASSWD_S)"
        NSLog("PostData: %@", post);
        
        
        let url: NSURL = NSURL(string: "http://localhost:8888/parking.php")!
        let postData:NSData = post.dataUsingEncoding(NSUTF8StringEncoding)!
        let postLength:NSString = String( postData.length )
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var reponseError: NSError?
        _ = "data=something"
        var response: NSURLResponse? = nil
        var urlData: NSData?
        
        do {
            urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
        } catch let error as NSError {
            reponseError = error
            print( error)
            urlData = nil
        }
        
//        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
//            
//        }
        
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!
            NSLog("Response code: %ld", res.statusCode);
            
            if (res.statusCode >= 200 && res.statusCode < 300){
                let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                NSLog("Response ==> %@", responseData);
                
                dispatch_async(dispatch_get_main_queue(), {
                    let parkData = parkingData()
                    parkData.getParking({ (parkings) -> Void in
                        
                        completion(parkings: parkings)
                    })
                
                    
                })
            }
        }
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return parkingList.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? CustomTableViewCell
        
        cell!.parkingNameLable.text = parkingList[indexPath.row].title
        cell!.parkingAddress.text = parkingList[indexPath.row].addressP
        cell!.tollLable.text = parkingList[indexPath.row].toll_car
        
        return cell!
    }
    


}

