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
    var filteredRooms = [PublicRoom]()
    var chosenRoom: PublicRoom?
    let cellID = "cellID"
    let searchController = UISearchController(searchResultsController: nil)

    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(RoomsViewController.promptForAddRoom))
        
        title = "Rooms"
        tableView.estimatedRowHeight = 72
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PublicRoomCell.self, forCellReuseIdentifier: cellID)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        observeRooms()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleReloadData()
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
            self.handleReloadData()
        })
    }
    
    //MARK: - Handler Methods
    
    func handleReloadData(){
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }

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
        let firebasePost = DataService.ds.REF_CHATROOMS.childByAutoId()
        
        if let unwrappedRoomName = roomName{
            let post: Dictionary<String, AnyObject> =
        
                ["RoomName": unwrappedRoomName as AnyObject,
                 "Author": CurrentUser._userName as AnyObject,
                 "AuthorPic": CurrentUser._profileImageUrl as AnyObject,
                 "timestamp": timestamp as AnyObject,
                 "posts": 0 as AnyObject,
                 "AuthorID" : authorID as AnyObject]

            firebasePost.setValue(post)
            
            handleReloadData()
        }
    }
    
    func showPostControllerForRoom(room: PublicRoom){
//        let feedController = FeedVC()
//            feedController.roomsController = self
//            feedController.parentRoom = room
        
        let postController = PostsVC()
            postController.roomsController = self
            postController.parentRoom = room
        
            var img: UIImage?
            if let url = room.AuthorPic{
                img = imageCache.object(forKey: url as NSString) as UIImage?
            }
            postController.messageImage = img
        
            navigationController?.pushViewController(postController, animated: true)
    }
    
    
    //MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let post = roomsArray[indexPath.row]
        let post: PublicRoom
        
        if searchController.isActive && searchController.searchBar.text != "" {
            post = filteredRooms[indexPath.row]
        } else {
            post = roomsArray[indexPath.row]
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? PublicRoomCell{
            cell.publicRoom = post
            return cell
        }else{
            return PublicRoomCell()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredRooms.count
        }
        return roomsArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room: PublicRoom
        
        room = searchController.isActive && searchController.searchBar.text != "" ? filteredRooms[indexPath.row] : roomsArray[indexPath.row]
        
        showPostControllerForRoom(room: room)
    }
    
    //MARK: - Search Delegate Methods
    
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        filteredRooms = roomsArray.filter{ room in
            return (room.RoomName?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
    
}//end RoomsViewController

extension RoomsViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}





