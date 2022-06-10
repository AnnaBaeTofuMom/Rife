//
//  MapViewController.swift
//  Rife - Simple Run Life
//
//  Created by 배경원 on 2021/11/17.
//

import UIKit
import SideMenu
import MarqueeLabel
import MapKit
import CoreLocation
import CloudKit
import RealmSwift
import Kingfisher
import SwiftyJSON
import Alamofire
import AuthenticationServices
import CoreMotion


class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    let localRealm = try! Realm()
    
    var currentOverlay: MKPolyline = MKPolyline()
    let locationManager: CLLocationManager = CLLocationManager()
    var previousCoordinate: CLLocationCoordinate2D?
    var points: [CLLocationCoordinate2D] = []
    
    var runMode:RunMode = .ready
    var recordImage: UIImage = UIImage()
    let fileManager = FileManager()
    var totalDistance: CLLocationDistance = CLLocationDistance()
    var totalRunTime: String = ""
    
    var timer = Timer()
    var (hours, minutes, seconds, fractions) = (0, 0, 0, 0)
    var currentWeather: String = ""
    var finalData: Data = Data()
    var recordMemo: String = ""
    var startTime: Date = Date()
    var endTime: Date = Date()
    let motionManager = CMMotionActivityManager()
    
    
    
    
    
    @IBOutlet var weatherIconView: UIImageView!
    @IBOutlet var recordView: UIImageView!
    @IBOutlet var mapKit: MKMapView!
    @IBOutlet var resultDistanceLabel: UILabel!
    @IBOutlet var resultTimeLabel: UILabel!
    @IBOutlet var runButton: UIButton!
    @IBOutlet var navigationBar: UIView!
    
    
    
    func fetchWeatherData() -> Void {
            guard let currentLocation = locationManager.location else { return }
            let lati = currentLocation.coordinate.latitude
            let longi = currentLocation.coordinate.longitude
                    let key = "e48c83dbb4739468d69bb4e998f8939d"
                    let url = "http://api.openweathermap.org/data/2.5/weather?lat=\(lati)&lon=\(longi)&appid=\(key)"
                    
            AF.request(url, method: .get).validate().responseJSON { response in
                switch response.result{
                case .success: guard let result = response.data else { return }
                    let json = JSON(result)
                    for item in json["weather"].arrayValue {
                        self.currentWeather = item["main"].stringValue
                        let icon = item["icon"].stringValue
                        let url = URL(string: "http://openweathermap.org/img/wn/\(icon)@2x.png")
                        self.weatherIconView.kf.setImage(with: url)
                        print("********success************")
                
                    }
                case .failure(let error):
                    print("***************This is error**************",error)
                    
                    
                }
            }
            
        }
    
    
    func generateMapImage() {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(coordinates: self.points)!
        options.size = CGSize(width: 240, height: 240)
        options.showsBuildings = true
        
        MKMapSnapshotter(options: options).start { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            let mapImage = snapshot.image
            
            let finalImage = UIGraphicsImageRenderer(size: mapImage.size).image { _ in
                mapImage.draw(at: .zero)
                
               let coordinates = self.points
                
                let points2 = coordinates.map { coordinate in
                    snapshot.point(for: coordinate)
                }
                
                let path = UIBezierPath()
                path.move(to: points2[0])
                
                for point in points2.dropFirst() {
                    path.addLine(to: point)
                }
                path.lineWidth = 7
                UIColor(hue: 0.6694, saturation: 1, brightness: 0.91, alpha: 1.0).setStroke()
                path.stroke()
            }
            
            self.recordImage = finalImage
        }
        
    }
    
    
 
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

            guard let location = locations.last
            else {return}
            let latitude = location.coordinate.latitude
            let longtitude = location.coordinate.longitude
        
       
        let point1 = CLLocationCoordinate2DMake(self.previousCoordinate?.latitude ?? location.coordinate.latitude, self.previousCoordinate?.longitude ?? location.coordinate.longitude)
            let point2: CLLocationCoordinate2D
            = CLLocationCoordinate2DMake(latitude, longtitude)
            self.points.append(point1)
            self.points.append(point2)
            
        let loc1 = CLLocation(latitude: self.previousCoordinate?.latitude ?? 0.0, longitude: self.previousCoordinate?.longitude ?? 0.0)
        let loc2 = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.units = .metric
        let addedDistance = loc1.distance(from: loc2)
        
        
        
            
        
        
        
        
        let stringDistance = distanceFormatter.string(fromDistance: totalDistance)
        self.resultDistanceLabel.text = "\(stringDistance)"

        let lineDraw = MKPolyline(coordinates: points, count:points.count)
        self.mapKit.addOverlay(lineDraw)
        
            self.totalDistance += addedDistance
            self.previousCoordinate = location.coordinate
    
        
        
        print("Im still updating")
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        weatherIconView.layer.cornerRadius = weatherIconView.frame.width / 2
        weatherIconView.layer.borderColor = UIColor(named: "black")?.cgColor
        weatherIconView.layer.borderWidth = 1
        fetchWeatherData()
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        
        self.mapKit.mapType = MKMapType.standard
        self.mapKit.showsUserLocation = true
        self.mapKit.setUserTrackingMode(.follow, animated: true)
        
        self.mapKit.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        
        
        
        
        navigationBar.layer.borderWidth = 1
        navigationBar.layer.borderColor = UIColor(named: "black")?.cgColor
        
        resultDistanceLabel.attributedText = outline(string: "0m", font: "NotoSansKR-Black", size: 40, outlineSize: 3, textColor: UIColor(red: 0.4941, green: 0.9922, blue: 0.6941, alpha: 1.0), outlineColor: .black)
        resultTimeLabel.attributedText = outline(string: "0:00:00", font: "NotoSansKR-Black", size: 40, outlineSize: 3, textColor: UIColor(red: 0.4941, green: 0.9922, blue: 0.6941, alpha: 1.0), outlineColor: .black)
        
        resultDistanceLabel.isHidden = true
        resultTimeLabel.isHidden = true
        setNotifications()
        
        motionManager.startActivityUpdates(to: .main) { activity in
            guard let activity = activity else {
                return
            }
            if self.runMode == .running{
                if activity.running == true || activity.walking == true {
                    if activity.stationary == false {
                        self.locationManager.startUpdatingLocation()
//                        print("user motion is running or walking and not stationary")
//                        print(activity)
                    } else {
                        self.locationManager.stopUpdatingLocation()
//                        print("user motion is running or walking but stationary")
//                        print(activity)
                    }
                    
                } else {
                    self.locationManager.stopUpdatingLocation()
//                    print("user motion is not running or walking")
//                    print(activity)
                }
            }
            
                    
        }
        
        //locationManager.startUpdatingLocation()
        
        
    }
    
    
    @objc func addbackGroundTime(_ notification:Notification) {
        if runMode == .running {
            //노티피케이션센터를 통해 값을 받아옴
            let time = notification.userInfo?["time"] as? Int ?? 0
            print("this is time: \(time)")
            //받아온 시간을 60으로 나눈 몫은 분
            hours += time/3600
            let leftTime = time%3600
            
            minutes += leftTime/60
            //받아온 시간을 60으로 나눈 나머지는 초
            seconds += leftTime%60
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.keepTimer), userInfo: nil, repeats: true)
        }
    }
    
    @objc func stopTimer() {
        timer.invalidate()
    }
    
    
    func setNotifications() {
            //백그라운드에서 포어그라운드로 돌아올때
            NotificationCenter.default.addObserver(self, selector: #selector(addbackGroundTime(_:)), name: NSNotification.Name("sceneWillEnterForeground"), object: nil)
            //포어그라운드에서 백그라운드로 갈때
            NotificationCenter.default.addObserver(self, selector: #selector(stopTimer), name: NSNotification.Name("sceneDidEnterBackground"), object: nil)
        }

    
    func checkUserLocationServicesAuthorization() {
        let authorizationStatus: CLAuthorizationStatus
        if #available(iOS 14, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            checkCurrentLocationAuthorization(authorizationStatus: authorizationStatus)
        }
    }
    
    func checkCurrentLocationAuthorization(authorizationStatus: CLAuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        case .restricted:
            print("restricted")
            goSetting()
        case .denied:
            print("denided")
            goSetting()
        case .authorizedAlways:
            print("always")
        case .authorizedWhenInUse:
            print("wheninuse")
            locationManager.startUpdatingLocation()
        @unknown default:
            print("unknown")
        }
        if #available(iOS 14.0, *) {
            let accuracyState = locationManager.accuracyAuthorization
            switch accuracyState {
            case .fullAccuracy:
                print("full")
            case .reducedAccuracy:
                print("reduced")
            @unknown default:
                print("Unknown")
            }
        }
    }
    
    func goSetting() {
        
        let alert = UIAlertController(title: "위치권한 요청", message: "러닝 거리 기록을 위해 항상 위치 권한이 필요합니다.", preferredStyle: .alert)
        let settingAction = UIAlertAction(title: "설정", style: .default) { action in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            // 열 수 있는 url 이라면, 이동
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { UIAlertAction in
            
        }
        
        alert.addAction(settingAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        checkUserLocationServicesAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function)
        checkUserLocationServicesAuthorization()
    }


    @IBAction func sideBarButtonClicked(_ sender: UIButton) {
    }
    
    
    @objc func keepTimer() {
        seconds += 1
        
        if seconds >= 60 {
            minutes += seconds/60
            seconds = seconds%60
        }
        
        if minutes >= 60 {
            hours += minutes/60
            minutes = minutes%60
        }
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        let hoursString = hours > 9 ? "\(hours)" : "0\(hours)"
        
        totalRunTime = "\(hoursString):\(minutesString):\(secondsString)"
        resultTimeLabel.text = self.totalRunTime
        
    }
    
    
    
    @IBAction func runButtonClicked(_ sender: UIButton) {
        if runMode == .ready {
            let authorizationStatus: CLAuthorizationStatus
            if #available(iOS 14, *) {
                authorizationStatus = locationManager.authorizationStatus
                
                
            } else {
                authorizationStatus = CLLocationManager.authorizationStatus()
            }
            checkCurrentLocationAuthorization(authorizationStatus: authorizationStatus)
            
            if authorizationStatus == .authorizedAlways {
                fetchWeatherData()
                resultTimeLabel.text = "00:00:00"
                resultDistanceLabel.text = "0m"
                
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.keepTimer), userInfo: nil, repeats: true)
                self.totalDistance = CLLocationDistance()
                self.previousCoordinate = locationManager.location?.coordinate
                locationManager.startUpdatingLocation()
                self.points = []
                self.mapKit.showsUserLocation = true
                self.mapKit.setUserTrackingMode(.follow, animated: true)
                runButton.setImage(UIImage(named: "Stop"), for: .normal)
                self.runMode = .running
                resultDistanceLabel.isHidden = false
                resultTimeLabel.isHidden = false
            } else {
                let alert = UIAlertController(title: "러닝 시작 실패", message: "위치 권한을 항상 허용해야 정확한 거리  측정이 가능합니다.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default) { action in
                    
                }
                let gosetting = UIAlertAction(title: "설정 변경", style: .default) { Action in
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    // 열 수 있는 url 이라면, 이동
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
                alert.addAction(ok)
                alert.addAction(gosetting)
                
                present(alert, animated: true) {
                    
                }
            }
            
            
            
        } else if runMode == .running {
            
            self.mapKit.showsUserLocation = false
            self.mapKit.setUserTrackingMode(.none, animated: true)
            runButton.setImage(UIImage(named: "Save"), for: .normal)
            self.runMode = .finished
            resultDistanceLabel.isHidden = false
            let distanceFormatter = MKDistanceFormatter()
            distanceFormatter.units = .metric
            let stringDistance = distanceFormatter.string(fromDistance: totalDistance)
            resultDistanceLabel.text = stringDistance
            resultTimeLabel.isHidden = false
            generateMapImage()
            timer.invalidate()
            
            locationManager.stopUpdatingLocation()
            endTime = Date()
            resultTimeLabel.text = self.totalRunTime
          
            
            
            
            
            

        } else if runMode == .finished {
            
            timer.invalidate()
            (hours, minutes, seconds, fractions) = (0, 0, 0, 0)
            resultTimeLabel.text = "00:00:00"
            resultDistanceLabel.text = "0m"
            // is when user tapped Save button
            self.mapKit.setUserTrackingMode(.follow, animated: true)
            locationManager.stopUpdatingLocation()
            
            print(recordImage)
            
//            let data: Data = recordImage.jpegData(compressionQuality: 0.1)!
            
            let overlays = mapKit.overlays
            mapKit.removeOverlays(overlays)
            runButton.setImage(UIImage(named: "Start"), for: .normal)
            self.runMode = .ready
            resultDistanceLabel.isHidden = true
            resultTimeLabel.isHidden = true
            self.mapKit.showsUserLocation = true
            
            let alert = UIAlertController(title: "기록 저장하기", message: "이 기록에 메모를 남겨주세요.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "저장", style: .default) { action in
                lazy var data = self.recordImage.jpegData(compressionQuality: 0.1)!
                let task = RecordObject(image: data, distance: self.totalDistance, time: self.totalRunTime, memo: alert.textFields?[0].text ?? "")
                try! self.localRealm.write {
                    self.localRealm.add(task)
                }
                print("saved")
            }
            let cancelAction = UIAlertAction(title: "기록 삭제", style: .destructive) { Action in
                
            }
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            alert.addTextField()
            present(alert, animated: true)
            
        } else {
            
        }
    }

}

//Polyline 의 모양을 컨트롤 해 주는 부분
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline
        else {
            print("can't draw polyline")
            return MKOverlayRenderer()
        }
        let renderer = MKPolylineRenderer(polyline: polyLine)
            renderer.strokeColor = UIColor(hue: 0.6694, saturation: 1, brightness: 0.91, alpha: 1.0)
            renderer.lineWidth = 10.0
            renderer.alpha = 1.0

        return renderer
    }
}

