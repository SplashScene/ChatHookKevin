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
    var messagesArray = [Message]()
    var messagesDictionary = [String: Message]()
    let cellID = "cellID"
    var timer: Timer?
    var userLat: Double?
    var userLong: Double?
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let newMessageImage = UIImage(named: "newmessage")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageImage, style: .plain, target: self, action: #selector(handleNewMessage))
        setupNavBarWithUser()
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellID")
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    //MARK: - Setup UI
    
    func setupNavBarWithUser(){
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
        if let profileImageUrl = CurrentUser._profileImageUrl{
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
            nameLabel.text = CurrentUser._userName
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
    }
    
    //MARK: - Observe Methods
    func observeUserMessages(){
        messagesArray = []
        let ref = DataService.ds.REF_USERMESSAGES.child(CurrentUser._postKey)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let userID = snapshot.key
            DataService.ds.REF_USERMESSAGES.child(CurrentUser._postKey!).child(userID).observe(.childAdded, with: { (snapshot) in
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
        
    //MARK: - Handlers
    
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
    
    func handleNewMessage(){
        let newMessageController = NewMessagesController()
            newMessageController.messagesController = self
        
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func calculateDistance(otherLocation: CLLocation) -> [String: AnyObject] {
        print("INSIDE CALCULATE DISTANCE")
        var distanceDictionary:[String: AnyObject]
        let myLocation = CurrentUser._location
        
        let distanceInMeters = myLocation?.distance(from: otherLocation)
        let distanceInMiles = (distanceInMeters! / 1000) * 0.62137
        
        let stringDistance = String(format: "%.2f", distanceInMiles)
        let passedString = "\(stringDistance) miles away"
        
        distanceDictionary = ["DistanceDouble": distanceInMiles as AnyObject, "DistanceString": passedString as AnyObject]
        
        return distanceDictionary
    }
    
    //MARK: - Show Controllers
    func showChatControllerForUser(user: User){
        let chatLogController = ChatViewController()
            chatLogController.senderId = CurrentUser._postKey
            chatLogController.senderDisplayName = CurrentUser._userName
            chatLogController.user = user
        
            var img: UIImage?
            if let url = user.profileImageUrl{
                img = imageCache.object(forKey: url as NSString) as UIImage?
            }
        
            chatLogController.messageImage = img
        
        let navController = UINavigationController(rootViewController: chatLogController)
        present(navController, animated: true, completion: nil)
        
    }
    
    func showProfileControllerForUser(user: User){
        let profileController = ProfileViewController()
            profileController.selectedUser = user
        
        let navController = UINavigationController(rootViewController: profileController)
        present(navController, animated: true, completion: nil)
    }
    
    //MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath as IndexPath) as! UserCell
        let message = messagesArray[indexPath.row]
        cell.message = message
        cell.accessoryType = UITableViewCellAccessoryType.detailButton
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let message = messagesArray[indexPath.row]
        guard let chatPartnerID = message.chatPartnerID() else { return }
        
        let ref = DataService.ds.REF_USERS.child(chatPartnerID)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
            let user = User(postKey: snapshot.key, dictionary: dictionary)
            self.showProfileControllerForUser(user: user)
            }, withCancel: nil)

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
