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
import RealmSwift
import Kingfisher
import SwiftyJSON
import Alamofire
import AuthenticationServices
import CoreMotion

class MapViewController: UIViewController {
    let customView = MapView()
    let localRealm = try! Realm()
    let locationManager: CLLocationManager = CLLocationManager()
    let fileManager = FileManager()
    let motionManager = CMMotionActivityManager()
    let leftNavButton = UIBarButtonItem()
    let rightNavButton = UIBarButtonItem()
    
    var currentOverlay: MKPolyline = MKPolyline()
    var previousCoordinate: CLLocationCoordinate2D?
    var points: [CLLocationCoordinate2D] = []
    var runMode:RunMode = .ready
    var recordImage: UIImage = UIImage()
    var totalDistance: CLLocationDistance = CLLocationDistance()
    var totalRunTime: String = ""
    var timer = Timer()
    var (hours, minutes, seconds, fractions) = (0, 0, 0, 0)
    var currentWeather: String = ""
    var finalData: Data = Data()
    var recordMemo: String = ""
    var startTime: Date = Date()
    var endTime: Date = Date()
    
    override func loadView() {
        super.loadView()
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        
        customView.mapView.mapType = MKMapType.standard
        customView.mapView.showsUserLocation = true
        customView.mapView.setUserTrackingMode(.follow, animated: true)
        customView.mapView.delegate = self
        
        setNotifications()
        setNavigator()
        
        motionManager.startActivityUpdates(to: .main) { activity in
            guard let activity = activity else { return }
            
            if self.runMode == .running{
                if activity.running == true || activity.walking == true {
                    if activity.stationary == false {
                        self.locationManager.startUpdatingLocation()
                    } else {
                        self.locationManager.stopUpdatingLocation()
                    }
                } else {
                    self.locationManager.stopUpdatingLocation()
                }
            }
        }
    }
    
    func setNavigator() {
        leftNavButton.image = UIImage(named: "rife_icon")?.withRenderingMode(.alwaysOriginal)
        rightNavButton.image = UIImage(named: "setting_icon")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = leftNavButton
        self.navigationItem.rightBarButtonItem = rightNavButton
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
    
    @objc func addbackGroundTime(_ notification:Notification) {
        if runMode == .running {
            let time = notification.userInfo?["time"] as? Int ?? 0
            hours += time/3600
            let leftTime = time%3600
            minutes += leftTime/60
            seconds += leftTime%60
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.keepTimer), userInfo: nil, repeats: true)
        }
    }
    
    @objc func stopTimer() {
        timer.invalidate()
    }
    
    func setNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(addbackGroundTime(_:)), name: NSNotification.Name("sceneWillEnterForeground"), object: nil)
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
            goSetting()
        case .denied:
            goSetting()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .authorizedAlways:
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
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(settingAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkUserLocationServicesAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkUserLocationServicesAuthorization()
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
        self.customView.timeLabel.text = self.totalRunTime
    }
    
    func showSaveAlert() {
        let alert = UIAlertController(title: "기록 저장하기", message: "이 기록에 메모를 남겨주세요.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "저장", style: .default) { action in
            lazy var data = self.recordImage.jpegData(compressionQuality: 0.1)!
            let task = RecordObject(image: data, distance: self.totalDistance, time: self.totalRunTime, memo: alert.textFields?[0].text ?? "")
            try! self.localRealm.write {
                self.localRealm.add(task)
            }
        }
        
        let cancelAction = UIAlertAction(title: "기록 삭제", style: .destructive)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.addTextField()
        
        present(alert, animated: true)
    }
    
    func resetTimeLabel() {
        self.customView.timeLabel.text = "00:00:00"
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
                resetTimeLabel()
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.keepTimer), userInfo: nil, repeats: true)
                self.totalDistance = CLLocationDistance()
                self.previousCoordinate = locationManager.location?.coordinate
                locationManager.startUpdatingLocation()
                self.points = []
                self.customView.mapView.showsUserLocation = true
                self.customView.mapView.setUserTrackingMode(.follow, animated: true)
                self.runMode = .running
            } else {
                let alert = UIAlertController(title: "러닝 시작 실패", message: "위치 권한을 항상 허용해야 정확한 거리  측정이 가능합니다.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default)
                let gosetting = UIAlertAction(title: "설정 변경", style: .default) { Action in
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
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
            self.customView.mapView.showsUserLocation = false
            self.customView.mapView.setUserTrackingMode(.none, animated: true)
            self.runMode = .finished
            let distanceFormatter = MKDistanceFormatter()
            distanceFormatter.units = .metric
            let stringDistance = distanceFormatter.string(fromDistance: totalDistance)

            generateMapImage()
            timer.invalidate()
            locationManager.stopUpdatingLocation()
            endTime = Date()
            self.customView.timeLabel.text = self.totalRunTime
        } else if runMode == .finished {
            timer.invalidate()
            (hours, minutes, seconds, fractions) = (0, 0, 0, 0)
            resetTimeLabel()
            self.customView.mapView.setUserTrackingMode(.follow, animated: true)
            locationManager.stopUpdatingLocation()
            let overlays = self.customView.mapView.overlays
            self.customView.mapView.removeOverlays(overlays)
            self.runMode = .ready
            self.customView.mapView.showsUserLocation = true
            
            showSaveAlert()
            
        }
    }
}

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

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let latitude = location.coordinate.latitude
        let longtitude = location.coordinate.longitude
        let point1 = CLLocationCoordinate2DMake(self.previousCoordinate?.latitude ?? location.coordinate.latitude, self.previousCoordinate?.longitude ?? location.coordinate.longitude)
        let point2: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longtitude)

        self.points.append(point1)
        self.points.append(point2)
        
        let loc1 = CLLocation(latitude: self.previousCoordinate?.latitude ?? 0.0, longitude: self.previousCoordinate?.longitude ?? 0.0)
        let loc2 = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.units = .metric
        let addedDistance = loc1.distance(from: loc2)
        let stringDistance = distanceFormatter.string(fromDistance: totalDistance)
        //self.resultDistanceLabel.text = "\(stringDistance)"
        let lineDraw = MKPolyline(coordinates: points, count:points.count)
        self.customView.mapView.addOverlay(lineDraw)
        self.totalDistance += addedDistance
        self.previousCoordinate = location.coordinate
    }
}
