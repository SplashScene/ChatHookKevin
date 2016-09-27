//
//  RoomsViewController.swift
//  ChatHook
//
//  Created by Kevin Farm on 7/18/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase

class RoomsViewController: UITableViewController {
    var roomsArray = [PublicRoom]()
    var chosenRoom: PublicRoom?
    let cellID = "cellID"

    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(RoomsViewController.promptForAddRoom))
        
        title = "Rooms"
        tableView.estimatedRowHeight = 72
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PublicRoomCell.self, forCellReuseIdentifier: cellID)
        
        observeRooms()
    }
    
    //MARK: - Observe Methods
    func observeRooms(){
        DataService.ds.REF_CHATROOMS.observe(.value, with: {
            snapshot in
            
            self.roomsArray = []
    
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let post = PublicRoom(key: snap.key)
                            post.setValuesForKeys(postDict)
                        self.roomsArray.insert(post, at: 0)
                    }
                }
            }
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        })
    }
    
    //MARK: - Handler Methods

    func promptForAddRoom(){
        let ac = UIAlertController(title: "Enter Room Name", message: "What is the name of your public room?", preferredStyle: .alert)
            ac.addTextField{ (textField: UITextField) in
                textField.placeholder = "You Room Name"
        }
        
            ac.addAction(UIAlertAction(title: "Submit", style: .default){[unowned self, ac](action: UIAlertAction!) in
                    let roomName = ac.textFields![0]
                    self.postToFirebase(roomName: roomName.text!)
            })
        
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
                ac.dismiss(animated: true, completion: nil)
            })
        present(ac, animated: true, completion: nil)
    }
    
    func postToFirebase(roomName: String?){
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let authorID = UserDefaults.standard.value(forKey: KEY_UID) as! String
        //let authorID = FIRAuth.auth()!.currentUser!.uid

        if let unwrappedRoomName = roomName{
            let post: Dictionary<String, AnyObject> =
        
                ["RoomName": unwrappedRoomName as AnyObject,
                 "Author": CurrentUser._userName as AnyObject,
                 "AuthorPic": CurrentUser._profileImageUrl as AnyObject,
                 "timestamp": timestamp as AnyObject,
                 "AuthorID" : authorID as AnyObject
            ]
            
            let firebasePost = DataService.ds.REF_CHATROOMS.childByAutoId()
                firebasePost.setValue(post)
            
            tableView.reloadData()
        }
    }
    
    func showPostControllerForRoom(room: PublicRoom){
        
        let postController = PostsVC()
            postController.roomsController = self
            postController.parentRoom = room
        
            var img: UIImage?
            if let url = room.AuthorPic{
                img = imageCache.object(forKey: url as NSString) as UIImage?
            }
            postController.messageImage = img
        
       // let postNavController = UINavigationController(rootViewController: postController)
           // presentViewController(postNavController, animated: true, completion: nil)
        navigationController?.pushViewController(postController, animated: true)
    }
    
    
    //MARK: - TableView Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = roomsArray[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? PublicRoomCell{
               cell.publicRoom = post
            return cell
        }else{
            return PublicRoomCell()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomsArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let room = roomsArray[indexPath.row]
        showPostControllerForRoom(room: room)
    }
    
    
}//end RoomsViewController





