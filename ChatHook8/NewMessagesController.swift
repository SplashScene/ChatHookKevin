//
//  NewMessagesController.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/22/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class NewMessagesController: UITableViewController {

    var messagesController: MessagesController?
    let cellID = "cellID"
    var groupedUsersArray = [GroupedUsers]()
    var blockedUsersArray = [String]()
    var usersArray1 = [User]()
    var usersArray2 = [User]()
    var usersArray3 = [User]()
    var userLat: Double?
    var userLong: Double?
    var timer: Timer?
    
    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.title = "People Near You"
        observeUsersOnline()
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellID")
        blockedUsersArray = []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //tableView.reloadData()
    }
    
    //MARK: - Observe Methods
    func observeUsersOnline(){
        
        groupedUsersArray = []

        let searchLat = Int(CurrentUser._location.coordinate.latitude)
        let searchLong = Int(CurrentUser._location.coordinate.longitude)

        let ref = DataService.ds.REF_USERSONLINE.child("\(searchLat)").child("\(searchLong)")
        
        
        ref.observe(.childAdded, with: { (snapshot) in
            let userID = snapshot.key
            var userLocation: CLLocation?
            
            let latLongRef = ref.child(userID)
            
            latLongRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    
                    userLocation = CLLocation(latitude: dictionary["userLatitude"] as! Double,
                                              longitude: dictionary["userLongitude"] as! Double)
                    
                    let userRef = DataService.ds.REF_USERS.child(userID)
                    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            let userPostKey = snapshot.key
                            let user = User(postKey: userPostKey, dictionary: dictionary)
                            user.location = userLocation
                            if let isBlockedUser = CurrentUser._blockedUsersArray?.contains(user.postKey){
                                user.isBlocked = isBlockedUser
                            }
                            
                            userRef.child("blocked_users").child(CurrentUser._postKey).observe(.value, with: { (snapshot) in
                                if let _ = snapshot.value as? NSNull{
                                    if user.postKey != CurrentUser._postKey{
                                        
                                        let distanceFromMe = self.messagesController!.calculateDistance(otherLocation: user.location)
                                        let distanceDouble = distanceFromMe["DistanceDouble"] as! Double
                                        user.distance = distanceDouble
                                        
                                        self.loadDistanceArrays(distanceDouble: user.distance!, user: user)
                                        
                                        self.attemptLoadOfSections()
                                    }
                                    
                                }else{
                                    print("\(user.userName) cock blocked me")
                                }
                                }, withCancel: nil)
                        }
                        
                        }, withCancel: nil)
                }
                }, withCancel: nil)
            
            }, withCancel: nil)
    }
    
    //MARK: - Load Handlers
    
    func loadDistanceArrays(distanceDouble: Double, user: User){
        switch distanceDouble{
            case 0...1.099:
                self.usersArray1.append(user)
                print("Added to UsersArray1")
                self.usersArray1.sort(by: { (user1, user2) -> Bool in
                    return user1.distance! < user2.distance!
                })
            case 1.1...5.0:
                self.usersArray2.append(user)
                self.usersArray2.sort(by: { (user1, user2) -> Bool in
                    return user1.distance! < user2.distance!
                })
            default:
                self.usersArray3.append(user)
                self.usersArray3.sort(by: { (user1, user2) -> Bool in
                    return user1.distance! < user2.distance!
                })
            }
    }
    
    func loadSections(){
        if usersArray1.count > 0 {
            self.groupedUsersArray.append(GroupedUsers(sectionName: "Within a mile", sectionUsers: self.usersArray1))
            print("Grouped Users Array Count is: \(groupedUsersArray.count)")
        }
        if usersArray2.count > 0 {
            self.groupedUsersArray.append(GroupedUsers(sectionName: "Within 5 miles", sectionUsers: self.usersArray2))
        }
        if usersArray3.count > 0 {
            self.groupedUsersArray.append(GroupedUsers(sectionName: "Over 5 miles", sectionUsers: self.usersArray3))
        }        
        handleReloadTable()
    }
    
    private func attemptLoadOfSections(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.loadSections), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable(){
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    func showProfileControllerForUser(user: User){
        let profileController = ProfileViewController()
        profileController.selectedUser = user
        
        let navController = UINavigationController(rootViewController: profileController)
        present(navController, animated: true, completion: nil)
    }
    
    //MARK: - TableView Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return groupedUsersArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedUsersArray[section].sectionUsers.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath as IndexPath) as! UserCell
        
            let user = groupedUsersArray[indexPath.section].sectionUsers[indexPath.row]
            
            if let stringDistance = user.distance {
                let unwrappedString = String(format: "%.2f", (stringDistance))
                let distanceString = "\(unwrappedString) miles away"
                cell.detailTextLabel?.text = distanceString
            }
            
                if user.isBlocked == true{
                    cell.backgroundColor = UIColor(r: 255, g: 99, b: 71)
                }else{
                    cell.backgroundColor = UIColor.white
                }
            
            cell.textLabel?.text = user.userName
            cell.accessoryType = UITableViewCellAccessoryType.detailButton
            
            if let profileImageUrl = user.profileImageUrl{
                cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            }
            return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true){
            let user = self.groupedUsersArray[indexPath.section].sectionUsers[indexPath.row]
            self.messagesController?.showChatControllerForUser(user: user)
        }
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        dismiss(animated: true){
//            let user = self.groupedUsersArray[indexPath.section].sectionUsers[indexPath.row]
//            self.messagesController?.showChatControllerForUser(user: user)
//        }
//    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let user = self.groupedUsersArray[indexPath.section].sectionUsers[indexPath.row]
        self.showProfileControllerForUser(user: user)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupedUsersArray[section].sectionName
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
}



