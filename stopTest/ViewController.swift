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
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var list:NSMutableArray!
    var point:MKPointAnnotation!
    var c:CLLocation!
    var parkingList = NSArray()
    var titleStringArray = NSMutableArray()
    
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
        
        if (postToServerFunction() == "01"){
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "OK!"
            alertView.message = "成功連線"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        point = MKPointAnnotation()
        //point.coordinate = CLLocationCoordinate2DMake(c.coordinate.latitude, c.coordinate.longitude) 120.66629
        point.coordinate = CLLocationCoordinate2DMake(24.136299, 120.66629)
        point.title = "台中市"
        point.subtitle = "所在位置"
        self.myMap.addAnnotation(point)
    
        //放大效果
        var track = CLLocationCoordinate2D(latitude: 24.136299, longitude: 120.66629)
        var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        var region = MKCoordinateRegion(center: track, span: span)
        
        //self.myMap.centerCoordinate = CLLocationCoordinate2DMake(c.coordinate.latitude, c.coordinate.longitude)
        self.myMap.centerCoordinate = CLLocationCoordinate2DMake(24.136299, 120.66629)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Location Manager Delegate stuff
    // If failed
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        location.stopUpdatingLocation()
        if ((error) != nil) {
            if (seenError == false) {
                seenError = true
                print(error)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        c = locationArray[0] as! CLLocation
        NSLog("緯度:%f, 精度:%f, 高度:%f", c.coordinate.latitude, c.coordinate.longitude, c.altitude)
    }
    
    //authorization status
    func locationManager(manager: CLLocationManager!,
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
    
    func postToServerFunction() -> String{
        let USERNAME_S = "101"
        let PASSWD_S = "台中"
        
        //var post:NSString = "username=\(username)&password=\(passwd)"
        var post:NSString = "CITY_NO=\(USERNAME_S)&CITY_NAME=\(PASSWD_S)"
        NSLog("PostData: %@", post);
        
        var url: NSURL = NSURL(string: "http://localhost:8888/parking.php")!
        //var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        var postData:NSData = post.dataUsingEncoding(NSUTF8StringEncoding)!
        var postLength:NSString = String( postData.length )
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var reponseError: NSError?
        var bodyBata = "data=something"
        var response: NSURLResponse? = nil
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!
            NSLog("Response code: %ld", res.statusCode);
            
            if (res.statusCode >= 200 && res.statusCode < 300){
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                NSLog("Response ==> %@", responseData);
                list = NSMutableArray()
                list.addObject(responseData)
                
                var parkData = parkingData()
                parkingList = parkData.getMovieDataFromArrar()
                
                for result in parkingList{
                    let title = result.objectForKey("parking_name") as! NSString
                    titleStringArray.addObject(title)
                }
                
            }
        }
        return "01"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleStringArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? CustomTableViewCell
        
        //var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? CustomTableViewCell
        
        if(cell == nil){
            cell = CustomTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        cell!.parkingNameLable.text = titleStringArray.objectAtIndex(indexPath.row) as? String
        cell!.parkingAddress.text = "123456"
        
        //cell!.textLabel?.text = titleStringArray.objectAtIndex(indexPath.row) as? String
        
        return cell!
    }
    


}

