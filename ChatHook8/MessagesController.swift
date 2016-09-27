//
//  MessagesController.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/22/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation


class MessagesController: UITableViewController {
    
    var profileView = ProfileViewController()

    let db = FIRDatabase.database().reference()
    var messagesArray = [Message]()
    var messagesDictionary = [String: Message]()
    let cellID = "cellID"
    let currentUserRef = DataService.ds.REF_USER_CURRENT
    var currentUser: User?
    var uid: String?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let newMessageImage = UIImage(named: "newMessageIcon_25")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageImage, style: .plain, target: self, action: #selector(handleNewMessage))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellID")
        
        checkIfUserIsLoggedIn()
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let message = messagesArray[indexPath.row]
        
        if let chatPartnerID = message.chatPartnerID(){
           DataService.ds.REF_USERMESSAGES.child(uid).child(chatPartnerID).removeValue(completionBlock: { (error, ref) in
            if error != nil{
                print("Failed to remove message", error)
                return
            }
            
            self.messagesDictionary.removeValue(forKey: chatPartnerID)
            self.attemptReloadOfTable()

           })
        }   
    }
    
    func observeUserMessages(){
        messagesArray = []
        let ref = db.child("user_messages").child(uid!)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let userID = snapshot.key
            DataService.ds.REF_USERMESSAGES.child(self.uid!).child(userID).observe(.childAdded, with: { (snapshot) in
                let messageID = snapshot.key
                self.fetchMessageWithMessageId(messageID: messageID)
                }, withCancel: nil)
            }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
            }, withCancel: nil)
    }
    
    private func fetchMessageWithMessageId(messageID: String){
        let messagesRef = DataService.ds.REF_MESSAGES.child(messageID)
        
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messagesArray.append(message)
                
                if let chatPartnerID = message.chatPartnerID(){
                    self.messagesDictionary[chatPartnerID] = message
                }
                
                self.attemptReloadOfTable()
            }
            }, withCancel: nil)
    }
    
    private func attemptReloadOfTable(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable(){
        self.messagesArray = Array(self.messagesDictionary.values)
        self.messagesArray.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil{
           // performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
            uid = FIRAuth.auth()?.currentUser?.uid
        }
    }
    
    func fetchUserAndSetupNavBarTitle(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        DataService.ds.REF_USERS.child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    self.navigationItem.title = dictionary["name"] as? String
                    let userPostKey = snapshot.key
                    self.currentUser = User(postKey: userPostKey, dictionary: dictionary)
                    self.setupNavBarWithUser(user: self.currentUser!)
                }
            },
            withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User){
        
        messagesArray.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
            profileImageView.translatesAutoresizingMaskIntoConstraints = false
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.layer.cornerRadius = 20
            profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl{
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.userName
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
    }
    
    func showChatControllerForUser(user: User){
        let chatLogController = ChatViewController()
            chatLogController.senderId = uid
            chatLogController.senderDisplayName = user.userName
            chatLogController.user = user
        
            var img: UIImage?
            if let url = user.profileImageUrl{
                img = imageCache.object(forKey: url as NSString) as UIImage?
            }
        
            chatLogController.messageImage = img
            
            navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func showProfileControllerForUser(user: User){
        let profileController = ProfileViewController()
            profileController.selectedUser = user
        
        let navController = UINavigationController(rootViewController: profileController)
        present(navController, animated: true, completion: nil)

    }
    
    func calculateDistance(otherLocation: CLLocation) -> [String: AnyObject] {
        var distanceDictionary:[String: AnyObject]
        let myLocation = CurrentUser._location
        
        let distanceInMeters = myLocation?.distance(from: otherLocation)
        let distanceInMiles = (distanceInMeters! / 1000) * 0.62137
        
        let stringDistance = String(format: "%.2f", distanceInMiles)
        let passedString = "\(stringDistance) miles away"
        
        distanceDictionary = ["DistanceDouble": distanceInMiles as AnyObject, "DistanceString": passedString as AnyObject]
        
        return distanceDictionary
        
    }

    func handleNewMessage(){
        let newMessageController = NewMessagesController()
            newMessageController.messagesController = self
            
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath as IndexPath) as! UserCell
        let message = messagesArray[indexPath.row]
        cell.message = message
        cell.accessoryType = UITableViewCellAccessoryType.detailButton
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let message = messagesArray[indexPath.row]
        guard let chatPartnerID = message.chatPartnerID() else { return }
        
        let ref = DataService.ds.REF_USERS.child(chatPartnerID)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
            let user = User(postKey: snapshot.key, dictionary: dictionary)
            self.showProfileControllerForUser(user: user)
            }, withCancel: nil)

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let message = messagesArray[indexPath.row]
        guard let chatPartnerID = message.chatPartnerID() else { return }
        
        let ref = DataService.ds.REF_USERS.child(chatPartnerID)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
            let user = User(postKey: snapshot.key, dictionary: dictionary)
            self.showChatControllerForUser(user: user)
            },
                               withCancel: nil)
        
    }
    
    
}
