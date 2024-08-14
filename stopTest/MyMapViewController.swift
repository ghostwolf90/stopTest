import UIKit
import MapKit
import CoreLocation

class MyMapViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    let defaultLatitude: CLLocationDegrees = 25.136299
    let defaultLongitude: CLLocationDegrees = 120.66629
    var currentLocation: CLLocation?
    
    var parkingList = [MainData]() {
        didSet {
            tableView.reloadData()
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        initializeParkingData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMapView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 延遲停止位置更新，避免 Metal 錯誤
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocation = location
        print("緯度:\(location.coordinate.latitude), 精度:\(location.coordinate.longitude), 高度:\(location.altitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            print("Location access denied/restricted")
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .notDetermined:
            print("Location status not determined")
        @unknown default:
            break
        }
    }
    
    // MARK: - Private Methods
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupMapView() {
        let point = MKPointAnnotation()
        point.coordinate = CLLocationCoordinate2DMake(defaultLatitude, defaultLongitude)
        point.title = "台中市"
        point.subtitle = "所在位置"
        myMapView.addAnnotation(point)
        
        centerMapOnLocation(latitude: defaultLatitude, longitude: defaultLongitude)
    }
    
    private func centerMapOnLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: locationCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        myMapView.setRegion(region, animated: true)
    }
    
    private func initializeParkingData() {
        let paris = MainData(addressP: "巴黎", title: "Eiffel Tower", toll_car: "123", time: "", lattitude: 48.8584, longitude: 2.2945)
        let giza = MainData(addressP: "埃及", title: "大金字塔", toll_car: "123", time: "", lattitude: 29.9792, longitude: 31.1342)
        let tokyo = MainData(addressP: "東京", title: "東京鐵塔", toll_car: "123", time: "", lattitude: 35.6586, longitude: 139.7454)
        
        parkingList.append(contentsOf: [paris, giza, tokyo])
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
        request.setValue(String(postString.count), forHTTPHeaderField: "Content-Length")
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
                    ParkingData.sharedInstance.getParking(completion: { parkings in
                        completion(parkings)
                    })
                }
            } else {
                print("Server responded with an error")
            }
        }
        task.resume()
    }
}

extension MyMapViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PlaceTableViewCell
        cell.setData(mapData: parkingList[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parking = parkingList[indexPath.row]
        
        DispatchQueue.main.async {
            self.centerMapOnLocation(latitude: parking.lattitude, longitude: parking.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: parking.lattitude, longitude: parking.longitude)
            annotation.title = parking.title
            annotation.subtitle = parking.addressP
            self.myMapView.addAnnotation(annotation)
        }
    }
}
