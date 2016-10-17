//
//  CurrentLocationViewcontrollerViewController.swift
//  ChatHook
//
//  Created by Kevin Farm on 6/10/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase


class GetLocation1: UIViewController {
    
    var registerViewController: FinishRegisterController?
    var locationManager:CLLocationManager? = nil
    let regionRadius:CLLocationDistance = 5000
    var userLocation: CLLocation?
    var otherUsersLocations: [UserLocation] = []
    var userOnline: Bool = false
    
    var userLatInt: Int!
    var userLngInt: Int!
    
    let currentUserRef = DataService.ds.REF_USER_CURRENT
    var blockedUsers: [String] = []
    var timer: Timer!
    
    //MARK: - Objects

    let mapView: MKMapView = {
        let map = MKMapView()
            map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    let topView: UIView = {
        let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.red
        return view
    }()
    
    lazy var logoutButton: UIButton = {
        let logButton = UIButton()
            logButton.translatesAutoresizingMaskIntoConstraints = false
            logButton.setTitle("Logout", for: .normal)
            logButton.titleLabel?.textColor = UIColor.white
            logButton.titleLabel?.font = UIFont(name: FONT_AVENIR_MEDIUM, size: 14.0)
            logButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
            logButton.isHidden = true
        return logButton
    }()
    
    let onlineLabel: UILabel = {
        let msgLabel = UILabel()
            msgLabel.translatesAutoresizingMaskIntoConstraints = false
            msgLabel.font = UIFont(name: FONT_AVENIR_MEDIUM, size:  18.0)
            msgLabel.backgroundColor = UIColor.clear
            msgLabel.textColor = UIColor.white
            msgLabel.text = "Getting Location..."
            msgLabel.sizeToFit()
        return msgLabel
    }()
 
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(topView)
        view.addSubview(mapView)
        
        locationManager = CLLocationManager()
        self.mapView.delegate = self
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        checkAuthorizationStatus()
        
        setupUI()
        mapView.addAnnotations(otherUsersLocations)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //MARK: - Setup Methods
    func checkAuthorizationStatus(){
        let authStatus = CLLocationManager.authorizationStatus()
            switch(authStatus){
                case .notDetermined: locationManager?.requestWhenInUseAuthorization(); print("In Auth switch statement1");return
                case .denied: showLocationServicesDeniedAlert(); print("In Auth switch statement2");return
                case .restricted: showLocationServicesDeniedAlert(); print("In Auth switch statement3"); return
                default:
                    if authStatus != .authorizedWhenInUse{
                        locationManager?.requestWhenInUseAuthorization()
                    }else{
                        locationManager?.requestLocation()
                    }
            }//end switch
    }//end checkAuthorizationStatus
    
    func setupUI(){
        topView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        topView.addSubview(onlineLabel)
        topView.addSubview(logoutButton)
        
        onlineLabel.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -8).isActive = true
        onlineLabel.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        
        logoutButton.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 8).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func userIsOnline(){
        userOnline = true
        logoutButton.isHidden = false
        onlineLabel.text = "Online"
        topView.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        
        if let currentUserLocation = CurrentUser._location{
             userLatInt = Int(currentUserLocation.coordinate.latitude)
             userLngInt = Int(currentUserLocation.coordinate.longitude)
            
            let usersOnlineRef = DataService.ds.REF_BASE.child("users_online").child("\(userLatInt!)").child("\(userLngInt!)").child(CurrentUser._postKey)
            let userLocal = ["userLatitude":currentUserLocation.coordinate.latitude, "userLongitude": currentUserLocation.coordinate.longitude]
            usersOnlineRef.setValue(userLocal)
            observeOtherUsersLocations()
        }
        
        centerMapOnLocation(location: CurrentUser._location!)
        self.mapView.showsUserLocation = true
        //addRadiusCircle(location: CurrentUser._location!)
    }

    //MARK: - Observe Methods
    func fetchCurrentUser(userLocation: CLLocation){
        print("In fetchCurrentUser")
        currentUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print("The current user ref is: \(self.currentUserRef)")
            if let dictionary = snapshot.value as? [String: AnyObject]{
                CurrentUser._postKey = snapshot.key
                CurrentUser._userName = dictionary["UserName"] as! String
                CurrentUser._location = userLocation
                CurrentUser._profileImageUrl = dictionary["ProfileImage"] as? String
                
                let blockedUsersRef = self.currentUserRef.child("blocked_users")
                    blockedUsersRef.observe(.value, with: { (snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                            for snap in snapshots{
                                let blockedUserID = snap.key
                                self.blockedUsers.append(blockedUserID)
                                self.handleLoadingBlockedUsers()
                            }
                        }
                    },
                    withCancel: nil)
                
                self.userIsOnline()
            }else{
                print("I aint got no dictionary dickhead")
            }
        }, withCancel: nil)
    }
    
    func observeOtherUsersLocations(){
        print("In observeOtherUsersLocations")
        let otherUsersLocationsRef = DataService.ds.REF_USERSONLINE.child("\(userLatInt!)").child("\(userLngInt!)")
            otherUsersLocationsRef.observe(.childAdded, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let otherUserId = snapshot.key
                    let otherUserLat = dictionary["userLatitude"] as! Double
                    let otherUserLong = dictionary["userLongitude"] as! Double
                    
                    let otherUsersRef = DataService.ds.REF_USERS.child(otherUserId)
                    otherUsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let userDict = snapshot.value as? [String: AnyObject]{
                            let otherUserName = userDict["UserName"] as! String
                            let otherUserImageUrl = userDict["ProfileImage"] as! String
                            
                            let otherUserLocation = UserLocation(latitude: otherUserLat, longitude: otherUserLong, name: otherUserName, imageName: otherUserImageUrl)
                            self.otherUsersLocations.append(otherUserLocation)
                            
                            self.timer?.invalidate()
                            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleAnnotations), userInfo: nil, repeats: false)
                        }
                    }, withCancel: nil)
                }
            }, withCancel: nil)
    }
    
    //MARK: - Handlers
    
    func handleCheckLocation(){
        print("Checking Location")
        locationManager?.requestLocation()
    }
    
    func handleAnnotations(){
        self.mapView.addAnnotations(self.otherUsersLocations)
    }
    
    func handleLoadingBlockedUsers(){
        CurrentUser._blockedUsersArray = blockedUsers
        print("Current User blocked array count is: \(CurrentUser._blockedUsersArray?.count)")
    }
    
    func handleLogout(){
        do{
            let usersOnlineRef = DataService.ds.REF_BASE.child("users_online").child("\(userLatInt)").child("\(userLngInt)").child(CurrentUser._postKey)
            usersOnlineRef.removeValue()
            UserDefaults.standard.removeObject(forKey: KEY_UID)
            
            try FIRAuth.auth()?.signOut()
        }catch let logoutError{
            print(logoutError)
        }
        dismiss(animated: true, completion: nil)
        
    }
}//end class


//MARK: - CLLocationManagerDelegate
extension GetLocation1: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location did fail with error")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("In location didUpdateLocations")
                if userLocation == nil{
                    userLocation = locations.first
                    //userLocation = CLLocation(latitude: 41.92413, longitude: -88.161242)
                    if CurrentUser._location == nil {
                        print("I don't even have a user")
                    }
                    if userLocation != nil{
                        fetchCurrentUser(userLocation: userLocation!)
                        if let items = self.tabBarController!.tabBar.items as [UITabBarItem]!{
                            for barTabItem in items{
                                barTabItem.isEnabled = true
                            }
                        }
                        if timer != nil{
                            timer.invalidate()
                        }
                        self.timer = Timer.scheduledTimer(timeInterval: 900.0, target: self, selector: #selector(self.handleCheckLocation), userInfo: nil, repeats: true)
                    }else{
                        print("I got NO location")
                    }
                   centerMapOnLocation(location: userLocation!)
                }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("In locationDidChangeAuthorizationStatus")
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            locationManager?.requestLocation()
        }
    }
   
    func showLocationServicesDeniedAlert(){
        print("In showLocationServicesDeniedAlert")
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}//end extension

//MARK: - Map View Delegate Functions

extension GetLocation1: MKMapViewDelegate{
    func centerMapOnLocation(location:CLLocation){
        let radiusFactor = userOnline ? 2 : 8
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * Double(radiusFactor), regionRadius * Double(radiusFactor))
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if (annotation is MKUserLocation){ return nil }
        
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "otherLocation") as? MKPinAnnotationView
            if annotationView == nil{
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "otherLocation")
            }else{
                annotationView?.annotation = annotation
            }
        
        //if let user = annotation as? User, let image = user.profile
        
        return annotationView
    }
    /*
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if let loc = userLocation.location{
            print("MAP VIEW LOCATION is: \(userLocation.coordinate.latitude) and \(userLocation.coordinate.longitude)")
            centerMapOnLocation(loc)
            addRadiusCircle(loc)
        }
    }
 
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
                annotationView.image = UIImage(named: "ProfileIcon25")
            return annotationView
        }else{
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
                annotationView.image = UIImage(named: "heart-full")
            return annotationView
        }
    }
    */
    //MARK: - Overlay Functions
    func addRadiusCircle(location: CLLocation){
        self.mapView.delegate = self
        let circle = MKCircle(center: location.coordinate, radius: 500 as CLLocationDistance)
        self.mapView.add(circle)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.red
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1
        return circle
        
    }
    
}//end extension
