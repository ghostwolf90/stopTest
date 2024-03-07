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
//                mainData.title = parking.object("parking_name") as! String
//                mainData.addressP = parking.object("parking_address") as! String
//                mainData.toll_car = parking.object("toll_car") as! String                
                self.parkingList.append(mainData)
//                //update ui
//                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
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
    private func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
        switch status {
        case CLAuthorizationStatus.restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.notDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        NotificationCenter.default.post(name: Notification.Name("LabelHasbeenUpdated"), object: nil)
        
        if (shouldIAllow == true) {
            NSLog("Location to Allowed")
            // Start location services
            location.startUpdatingLocation()
        } else {
            NSLog("Denied access: \(location)")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //關閉計算目前行動裝置所在位置功能
        location.stopUpdatingLocation()
    }
    
    func postToServerFunction(completion: @escaping ([String]) -> Void) {
        let USERNAME_S = "101"
        let PASSWD_S = "台中"
        
        let postString = "CITY_NO=\(USERNAME_S)&CITY_NAME=\(PASSWD_S)"
        print("PostData: \(postString)")
        
        guard let url = URL(string: "http://localhost:8888/parking.php") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        request.setValue(String(describing: postString.count), forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "No error description")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode {
                print("Response ==> \(String(describing: String(data: data, encoding: .utf8)))")
                
                DispatchQueue.main.async {
                    let parkData = parkingData()
                    parkData.getParking(completion: { parkings in
                        completion(parkings)
                    })
                }
            } else {
                print("Server responded with an error")
            }
        }
        
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as? CustomTableViewCell
        cell!.parkingNameLable.text = parkingList[indexPath.row].title
        cell!.parkingAddress.text = parkingList[indexPath.row].addressP
        cell!.tollLable.text = parkingList[indexPath.row].toll_car
        return cell!
    }
    
}

