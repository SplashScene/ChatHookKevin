//
//  ProfileViewController.swift
//  ChatHook
//
//  Created by Kevin Farm on 9/12/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController {
    var collectionView: UICollectionView!
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var photoChoice: String?
    var galleryArray = [GalleryImage]()
    var timer: Timer?
    var selectedUser: User?
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingView: UIView?
    
    //MARK: - Properties
    let backgroundImageView: UIImageView = {
        let backImageView = UIImageView()
            backImageView.translatesAutoresizingMaskIntoConstraints = false
            backImageView.image = UIImage(named: "background1")
            backImageView.contentMode = .scaleAspectFill
        return backImageView
    }()
    
    let addPhotoBlockUserButton: UIButton = {
        let addPicBtn = UIButton()
            addPicBtn.translatesAutoresizingMaskIntoConstraints = false
        return addPicBtn
    }()
    
    lazy var profileChatButton: UIButton = {
        let btnImage = UIImage(named: "chatIconRev")
        let profChatButton = UIButton()
            profChatButton.translatesAutoresizingMaskIntoConstraints = false
            profChatButton.setImage(btnImage, for: .normal)
            profChatButton.addTarget(self, action: #selector(ProfileViewController.handleShowChatControllerForSelectedUser), for: .touchUpInside)
        return profChatButton
    }()
    
    let profileImageView: MaterialImageView = {
        let imageView = MaterialImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
     
    let currentUserNameLabel: UILabel = {
        let nameLabel = UILabel()
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.alpha = 1.0
            nameLabel.font = UIFont(name: "Avenir Medium", size:  18.0)
            nameLabel.backgroundColor = UIColor.clear
            nameLabel.textColor = UIColor.white
            nameLabel.sizeToFit()
            nameLabel.textAlignment = NSTextAlignment.center
        return nameLabel
    }()
    
    let distanceLabel: UILabel = {
        let distLabel = UILabel()
            distLabel.translatesAutoresizingMaskIntoConstraints = false
            distLabel.alpha = 1.0
            distLabel.font = UIFont(name: "Avenir Medium", size:  14.0)
            distLabel.backgroundColor = UIColor.clear
            distLabel.textColor = UIColor.white
            distLabel.sizeToFit()
            distLabel.textAlignment = NSTextAlignment.center
        return distLabel
    }()
    
    let addPhotosToGalleryLabel: UILabel = {
        let galleryLabel = UILabel()
            galleryLabel.translatesAutoresizingMaskIntoConstraints = false
            galleryLabel.isHidden = false
            galleryLabel.font = UIFont(name: "Avenir Medium", size:  18.0)
            galleryLabel.backgroundColor = UIColor.clear
            galleryLabel.textColor = UIColor.white
            galleryLabel.sizeToFit()
            galleryLabel.textAlignment = NSTextAlignment.center
            galleryLabel.text = "Add Photos to Your Gallery"
        return galleryLabel
    }()
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = nil
        setupMainView()
        
        collectionView!.register(GalleryCollectionCell.self, forCellWithReuseIdentifier: "Cell")
        
        checkUserAndSetupUI()
        setupBackgroundImageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //MARK: - Setup Views
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView!.allowsMultipleSelection = editing
        
        let indexPaths = collectionView!.indexPathsForVisibleItems as [NSIndexPath]
            for indexPath in indexPaths{
                collectionView!.deselectItem(at: indexPath as IndexPath, animated: false)
                let cell = collectionView!.cellForItem(at: indexPath as IndexPath) as! GalleryCollectionCell
                    cell.editing = editing
            }
        
        if !editing{
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func setupCollectionView(){
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setupMainView(){
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        view.addSubview(backgroundImageView)
        view.addSubview(addPhotoBlockUserButton)
        view.addSubview(profileChatButton)
        
            if selectedUser != nil{
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
            }else{
                navigationItem.leftBarButtonItem = editButtonItem
            }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
            layout.itemSize = CGSize(width: screenWidth / 5, height: 120)
        
        let frame = CGRect(x: 0, y: view.center.y, width: view.frame.width, height: view.frame.height / 2 - 44)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        collectionView.addSubview(addPhotosToGalleryLabel)
        
        addPhotosToGalleryLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        addPhotosToGalleryLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true

        self.view.addSubview(collectionView)
    }
    
    func setupBackgroundImageView(){
        backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        backgroundImageView.addSubview(profileImageView)
        backgroundImageView.addSubview(currentUserNameLabel)
        backgroundImageView.addSubview(distanceLabel)
        
        profileImageView.centerXAnchor.constraint(equalTo: backgroundImageView.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        currentUserNameLabel.centerXAnchor.constraint(equalTo: backgroundImageView.centerXAnchor).isActive = true
        currentUserNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        
        distanceLabel.centerXAnchor.constraint(equalTo: backgroundImageView.centerXAnchor).isActive = true
        distanceLabel.topAnchor.constraint(equalTo: currentUserNameLabel.bottomAnchor, constant: 8).isActive = true
        
        addPhotoBlockUserButton.centerXAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 24).isActive = true
        addPhotoBlockUserButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        addPhotoBlockUserButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        addPhotoBlockUserButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        profileChatButton.centerXAnchor.constraint(equalTo: profileImageView.leftAnchor, constant: -24).isActive = true
        profileChatButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        profileChatButton.widthAnchor.constraint(equalToConstant: 54).isActive = true
        profileChatButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    func checkUserAndSetupUI(){
        if selectedUser == nil{
            let btnImage = UIImage(named: "add_photo_btn")
            self.profileImageView.loadImageUsingCacheWithUrlString(urlString: CurrentUser._profileImageUrl)
            self.currentUserNameLabel.text = CurrentUser._userName
            self.navigationItem.title = CurrentUser._userName
            self.addPhotoBlockUserButton.setImage(btnImage, for: .normal)
            self.addPhotoBlockUserButton.addTarget(self, action: #selector(handleAddPhotoButtonTapped), for: .touchUpInside)
            self.profileChatButton.isHidden = true
            observeGallery(uid: CurrentUser._postKey)
        }else if selectedUser?.isBlocked == false{
            let btnImage = UIImage(named: "unblock")
            setupSelectedUserProfile()
            observeGallery(uid: (selectedUser?.postKey)!)
            addPhotosToGalleryLabel.text = "No Photos in Gallery"
            self.addPhotoBlockUserButton.setImage(btnImage, for: .normal)
            self.addPhotoBlockUserButton.addTarget(self, action: #selector(handleBlockUserTapped), for: .touchUpInside)
            self.profileChatButton.isHidden = false
        }else{
            let btnImage = UIImage(named: "block")
            setupSelectedUserProfile()
            observeGallery(uid: (selectedUser?.postKey)!)
            addPhotosToGalleryLabel.text = "No Photos in Gallery"
            self.addPhotoBlockUserButton.setImage(btnImage, for: .normal)
            self.addPhotoBlockUserButton.addTarget(self, action: #selector(handleUnblockUserTapped), for: .touchUpInside)
            self.profileChatButton.isHidden = false
        }
    }
    
    func setupSelectedUserProfile(){
        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: (self.selectedUser?.profileImageUrl)!)
        self.currentUserNameLabel.text = self.selectedUser?.userName
            if let stringDistance = self.selectedUser?.distance {
                let unwrappedString = String(format: "%.2f", (stringDistance))
                self.distanceLabel.text = "\(unwrappedString) miles away"
            }
        self.navigationItem.title = self.selectedUser?.userName
    }

    //MARK: - Handlers
    
    func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    func handleDelete(){
        let indexPaths = collectionView!.indexPathsForSelectedItems! as [NSIndexPath]
        for indexPath in indexPaths{
            let indexPosition = indexPath.item
                let galleryItem = galleryArray[indexPosition]
                    if let cellID = galleryItem.postKey{
                        DataService.ds.REF_USERS_GALLERY.child(CurrentUser._postKey).child(cellID).removeValue()
                        DataService.ds.REF_GALLERYIMAGES.child(cellID).removeValue()
                        galleryArray.remove(at: indexPosition)
                        attemptReloadOfTable()
                    }
            }
        collectionView!.deleteItems(at: indexPaths as [IndexPath])
    }
    
    func handleAddPhotoButtonTapped(){
            let alertController = UIAlertController(title: "Edit/Add Photo", message: "Do you want to add to gallery or edit your profile picture", preferredStyle: .alert)
            let buttonOne = UIAlertAction(title: "Edit Profile Picture", style: .default) { (action) in
                self.photoChoice = "Profile"
                self.pickPhoto()
            }
            let buttonTwo = UIAlertAction(title: "Add to Photo Gallery", style: .default) { (action) in
                self.photoChoice = "Gallery"
                self.pickPhoto()
            }
            let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                print("Inside Cancel")
            }
            
            alertController.addAction(buttonOne)
            alertController.addAction(buttonTwo)
            alertController.addAction(buttonCancel)
            
            present(alertController, animated: true, completion: nil)
    }
    
    private func getMediaFrom(type: CFString){
        let mediaPicker = UIImagePickerController()
            mediaPicker.delegate = self
            mediaPicker.mediaTypes = [type as String]
        
        present(mediaPicker, animated: true, completion: nil)
    }
    
    func handleBlockUserTapped(){
        let alert = UIAlertController(title: "Block User", message: "Are you sure that you want to BLOCK this user?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction) in
            let currentUserRef = DataService.ds.REF_USER_CURRENT
            let blockedUserID = self.selectedUser!.postKey
            currentUserRef.child("blocked_users").updateChildValues([blockedUserID: 1])
            self.selectedUser?.isBlocked = true
            self.addPhotoBlockUserButton.setImage(UIImage(named: "block"), for: .normal)
            self.addPhotoBlockUserButton.addTarget(self, action: #selector(self.handleUnblockUserTapped), for: .touchUpInside)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func handleUnblockUserTapped(){let alert = UIAlertController(title: "Unblock User", message: "Are you sure that you want to UNBLOCK this user?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction) in
            let currentUserRef = DataService.ds.REF_USER_CURRENT
            let blockedUserID = self.selectedUser!.postKey
            currentUserRef.child("blocked_users").child(blockedUserID).removeValue()
            CurrentUser._blockedUsersArray = CurrentUser._blockedUsersArray?.filter({$0 != blockedUserID})
            self.selectedUser?.isBlocked = false
            self.addPhotoBlockUserButton.setImage(UIImage(named: "unblock"), for: .normal)
            self.addPhotoBlockUserButton.addTarget(self, action: #selector(self.handleBlockUserTapped), for: .touchUpInside)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func attemptReloadOfTable(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadGallery), userInfo: nil, repeats: false)
    }
    
    func handleReloadGallery(){
        DispatchQueue.main.async{
            self.collectionView.reloadData()
        }
    }
    
    func handleShowChatControllerForSelectedUser(){
        let chatLogController = ChatViewController()
            chatLogController.senderId = CurrentUser._postKey
            chatLogController.senderDisplayName = CurrentUser._userName
            chatLogController.user = selectedUser
        
        var img: UIImage?
        if let url = selectedUser?.profileImageUrl{
            img = imageCache.object(forKey: url as NSString) as UIImage?
        }
        
        chatLogController.messageImage = img
        
        let navController = UINavigationController(rootViewController: chatLogController)
        present(navController, animated: true, completion: nil)
        
    }

    
    //MARK: - Observe Method
    func observeGallery(uid: String){
        //guard let uid = FIRAuth.auth()?.currentUser!.uid else { return }
        let userGalleryPostRef = DataService.ds.REF_USERS_GALLERY.child(uid)
        
        userGalleryPostRef.observe(.childAdded, with: { (snapshot) in
            let galleryId = snapshot.key
            let galleryPostRef = DataService.ds.REF_GALLERYIMAGES.child(galleryId)
            
            galleryPostRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        let galleryPost = GalleryImage(key: snapshot.key)
                        galleryPost.setValuesForKeys(dictionary)
                        self.galleryArray.append(galleryPost)
                        
                        self.attemptReloadOfTable()
                    }
                }, withCancel: nil)
            }, withCancel: nil)
    }
    
    //MARK: - Zoom In and Out
    func performZoomInForStartingImageView(startingView: UIView, photoImage: UIImageView){
        self.startingView = startingView
        
        startingFrame = startingView.superview?.convert(startingView.frame, to: nil)
        
        let zoomingView = UIImageView(frame: startingFrame!)
            zoomingView.backgroundColor = UIColor.red
            zoomingView.isUserInteractionEnabled = true
            zoomingView.contentMode = .scaleAspectFill
            zoomingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
            zoomingView.image = photoImage.image
        if let keyWindow = UIApplication.shared.keyWindow{
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView!.alpha = 1
                self.startingView?.isHidden = true
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingView.center = keyWindow.center
                }, completion: nil)
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view{
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
                }, completion: { (completed) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingView?.isHidden = false
            })
        }
    }
}//end class

//MARK: - Extension UICollectionView

extension ProfileViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        addPhotosToGalleryLabel.isHidden = galleryArray.count > 0
        
        let galleryImage = galleryArray[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! GalleryCollectionCell
            cell.gallery = galleryImage
            cell.editing = isEditing
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing{
            if let cell = collectionView.cellForItem(at: indexPath as IndexPath),
                let cellImageView = cell.contentView.subviews[0] as? UIImageView{
                performZoomInForStartingImageView(startingView: cell.contentView, photoImage: cellImageView)
                navigationItem.rightBarButtonItem = nil
            }
        }else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleDelete))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing{
            if collectionView.indexPathsForSelectedItems!.count == 0{
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
}//end extension


