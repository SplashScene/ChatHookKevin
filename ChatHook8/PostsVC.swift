//
//  PostsVC.swift
//  driveby_Showcase
//
//  Created by Kevin Farm on 4/13/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import MobileCoreServices
import AVFoundation
import Social


class PostsVC: UIViewController{
    var profileView: ProfileViewController?
    var roomsController: RoomsViewController?
    var commentViewController: CommentViewController?
    var cellID = "cellID"
    var postedImage: UIImage?
    var postedVideo: NSURL?
    var postedText: String?
    var messageImage: UIImage?
    var parentRoom: PublicRoom?
    var timer: Timer?
    var navBar: UINavigationBar = UINavigationBar()
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingView: UIView?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playButton: UIButton?
    var activityIndicator: UIActivityIndicatorView?
    
    var postsArray = [UserPost]()
    var preventAnimation = Set<NSIndexPath>()
    
    let topView: MaterialView = {
        let view = MaterialView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.white
        return view
    }()
    
    let postTextField: MaterialTextField = {
        let ptf = MaterialTextField()
            ptf.placeholder = "What's on your mind?"
            ptf.translatesAutoresizingMaskIntoConstraints = false
        return ptf
    }()
    
    lazy var imageSelectorView: UIImageView = {
        let isv = UIImageView()
            isv.translatesAutoresizingMaskIntoConstraints = false
            isv.image = UIImage(named: "cameraIcon")
            isv.contentMode = .scaleAspectFill
            isv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageSelector)))
            isv.isUserInteractionEnabled = true
        return isv
    }()
    
    lazy var postButton: MaterialButton = {
        let pb = MaterialButton()
            pb.translatesAutoresizingMaskIntoConstraints = false
            pb.setTitle("Post", for: .normal)
            pb.isUserInteractionEnabled = false
            pb.alpha = 0.5
            pb.addTarget(self, action: #selector(handlePostButtonTapped), for: .touchUpInside)
        return pb
    }()

    let postTableView: UITableView = {
        let ptv = UITableView()
            ptv.translatesAutoresizingMaskIntoConstraints = false
            ptv.backgroundColor = UIColor(r: 220, g: 220, b: 220)
            ptv.allowsSelection = false
        return ptv
    }()
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.addSubview(topView)
        view.addSubview(postTableView)
        
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.register(testPostCell.self, forCellReuseIdentifier: "cellID")
        postTableView.estimatedRowHeight = 375
        postTextField.delegate = self
        
        setupTopView()
        setupPostTableView()
        setupNavBarWithUserOrProgress(progress: nil)
        observePosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleReloadPosts()
    }
    
    //MARK: - Setup Methods
    func setupNavBarWithUserOrProgress(progress:String?){
        
        let titleView = UIView()
            titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 60)
        
        let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
            profileImageView.translatesAutoresizingMaskIntoConstraints = false
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.layer.cornerRadius = 15
            profileImageView.clipsToBounds = true
            profileImageView.image = messageImage
        
        containerView.addSubview(profileImageView)
        
        profileImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let nameLabel = UILabel()
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.font = UIFont(name: "Avenir-Medium", size: 14.0)
        
                if let progressText = progress{
                    nameLabel.text = progressText
                    nameLabel.textColor = UIColor.red
                }else{
                    nameLabel.text = parentRoom?.RoomName
                    nameLabel.textColor = UIColor.darkGray
                }
        
        containerView.addSubview(nameLabel)
        
        nameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
    }
    
    func setupTopView(){
        //need x, y, width and height constraints
        topView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: view.topAnchor, constant: 72).isActive = true
        topView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        topView.addSubview(postTextField)
        topView.addSubview(imageSelectorView)
        topView.addSubview(postButton)
        
        postTextField.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 8).isActive = true
        postTextField.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        postTextField.widthAnchor.constraint(equalToConstant: 225).isActive = true
        postTextField.heightAnchor.constraint(equalTo: topView.heightAnchor, constant: -16).isActive = true
        
        imageSelectorView.leftAnchor.constraint(equalTo: postTextField.rightAnchor, constant: 8).isActive = true
        imageSelectorView.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        imageSelectorView.widthAnchor.constraint(equalToConstant: 37).isActive = true
        imageSelectorView.heightAnchor.constraint(equalTo: topView.heightAnchor, constant: -16).isActive = true
        
        postButton.leftAnchor.constraint(equalTo: imageSelectorView.rightAnchor, constant: 8).isActive = true
        postButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        postButton.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -8).isActive = true
        postButton.heightAnchor.constraint(equalTo: topView.heightAnchor, constant: -16).isActive = true
    }
    
    func setupPostTableView(){
        postTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        postTableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 8).isActive = true
        postTableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16).isActive = true
        postTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    //MARK: - Handler Methods
    func handleBack(){
        dismiss(animated: true, completion: nil)
    }
    
    func handleImageSelector(){
        let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        { (alert:UIAlertAction) in
            sheet.dismiss(animated: true, completion: nil)
        }
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert: UIAlertAction) in
            self.takePhotoWithCamera()
        }
        
        let photoLibary = UIAlertAction(title: "Photo Library", style: .default)
        { (alert: UIAlertAction) in
            self.getMediaFrom(type: kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Video Library", style: .default)
        { (alert: UIAlertAction) in
            self.getMediaFrom(type: kUTTypeMovie)
        }
        
        sheet.addAction(takePhoto)
        sheet.addAction(photoLibary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    private func getMediaFrom(type: CFString){
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        
        present(mediaPicker, animated: true, completion: nil)
    }
    
    func handlePostButtonTapped(){
        
        postedText = postTextField.text
        
        if let unwrappedImage = postedImage{
            uploadToFirebaseStorageUsingSelectedMedia(image: unwrappedImage, video: nil, completion: { (imageUrl) in
                self.enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl(metadata: "image/jpg", postText: self.postedText, thumbnailURL: nil, fileURL: imageUrl)
                //self.enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl("image/jpg", thumbnailURL: nil, fileURL:imageUrl)
            })
            
        }else if let unwrappedVideo = postedVideo{
            uploadToFirebaseStorageUsingSelectedMedia(image: nil, video: unwrappedVideo, completion: { (imageUrl) in
                //                self.enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl("video/mp4", postText: self.postedText, thumbnailURL: nil, fileURL: imageUrl)
                //self.enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl("video/mp4",thumbnailURL: nil, fileURL:imageUrl)
            })
        }else{
            self.enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl(metadata: "text", postText: postedText, thumbnailURL: nil, fileURL: nil)
        }
    }
    
    func handleReloadPosts(){
        DispatchQueue.main.async{
            self.postTableView.reloadData()
        }
    }
    
    func handleShare(shareView: UIView){
        let sharePosition = shareView.convert(CGPoint(x: 0, y: 0), to: self.postTableView)
        let indexPath = self.postTableView.indexPathForRow(at: sharePosition)
        let cell = self.postTableView.cellForRow(at: indexPath!) as? testPostCell
        
        let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        
            if let postText = cell?.descriptionText.text{
                vc?.setInitialText("Check out this great post from ChatHook: \n \(postText)")
            }else{
                vc?.setInitialText("Check out this great post from ChatHook:")
            }
            
            if let image = cell?.showcaseImageView.image{
                vc?.add(image)
            }
      
        present(vc!, animated: true, completion: nil)
    }
    
    func handleProfile(profileView: UIView){
        let profileViewPosition = profileView.convert(CGPoint(x: 0, y: 0), to: self.postTableView)
        if let indexPath = self.postTableView.indexPathForRow(at: profileViewPosition){
            let userPost = postsArray[indexPath.row]
            let ref = DataService.ds.REF_USERS.child(userPost.fromId!)
                
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
                    let user = User(postKey: snapshot.key, dictionary: dictionary)
                    self.showProfileControllerForUser(user: user)
                    }, withCancel: nil)
        }
    }
    
    func handleCommentTapped(commentView: UIView){
        let commentViewPosition = commentView.convert(CGPoint(x: 0, y: 0), to: self.postTableView)
        if let indexPath = self.postTableView.indexPathForRow(at: commentViewPosition){
            let userPost = postsArray[indexPath.row]
            let commentViewController = CommentViewController()
                commentViewController.postForComment = userPost
            let navController = UINavigationController(rootViewController: commentViewController)
            present(navController, animated: true, completion: nil)
        }
    }

    //MARK: - Observe Methods
    func observePosts(){
        guard let roomID = parentRoom?.postKey else { return }
        let roomPostsRef = DataService.ds.REF_POSTSPERROOM.child(roomID)
        
        roomPostsRef.observe(.childAdded, with: { (snapshot) in
            let postID = snapshot.key
            let postsRef = DataService.ds.REF_POSTS.child(postID)
            
            postsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let post = UserPost(key: snapshot.key)
                post.setValuesForKeys(dictionary)
                
                self.postsArray.insert(post, at: 0)
                
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadPosts), userInfo: nil, repeats: false)
                },
                withCancel: nil)
            }, withCancel: nil)
    }
    
    func adjustLikesInArrayDisplay(sender:UIButton){
        let buttonPosition = sender.convert(CGPoint(x: 0, y: 0), to: self.postTableView)
        let indexPath = self.postTableView.indexPathForRow(at: buttonPosition)
        let cell = self.postTableView.cellForRow(at: indexPath!) as? testPostCell
        let post = postsArray[indexPath!.row]
        var intLikes = Int(post.likes)
        if sender.tag == 1{
            intLikes += 1
            let adjustedLikes = NSNumber(value: Int32(intLikes))
            post.likes = adjustedLikes
            cell?.likeCount.text = "\(Int(post.likes))"
            cell?.likesLabel.text = intLikes == 1 ? "Like" : "Likes"
        }else{
            intLikes -= 1
            let adjustedLikes = NSNumber(value: Int32(intLikes))
            post.likes = adjustedLikes
            cell?.likeCount.text = "\(Int(post.likes))"
            cell?.likesLabel.text = intLikes == 1 ? "Like" : "Likes"
        }
    }
    
    func showProfileControllerForUser(user: User){
        let profileController = ProfileViewController()
            profileController.selectedUser = user
        
        let navController = UINavigationController(rootViewController: profileController)
        present(navController, animated: true, completion: nil)
    }
    
   //MARK: - Zoom In and Out Methods
    
    func performZoomInForStartingImageView(startingImageView: UIImageView){
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingView = UIImageView(frame: startingFrame!)
            zoomingView.backgroundColor = UIColor.red
            zoomingView.image = startingImageView.image
            zoomingView.isUserInteractionEnabled = true
            zoomingView.contentMode = .scaleAspectFill
            zoomingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow{
            keyWindow.addSubview(zoomingView)
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingView)
                
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut,
                           animations: {
                                self.blackBackgroundView!.alpha = 1
                                self.startingView?.isHidden = true

                                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
        
                                zoomingView.frame = CGRect(x: 0,
                                                           y: 0,
                                                           width: keyWindow.frame.width,
                                                           height: height)
                                zoomingView.center = keyWindow.center
                            },
                           completion: nil)
        }
  
    }

    func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view{
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut,
                           animations: {
                                zoomOutImageView.frame = self.startingFrame!
                                self.blackBackgroundView?.alpha = 0
                            },
                           completion: { (completed) in
                                zoomOutImageView.removeFromSuperview()
                                self.startingView?.isHidden = false
                            })
        }
    }
    
    //MARK: - Video Player Methods
    
    func handlePlayPostVideo(sender: UIButton){
        
        let buttonPosition = sender.convert(CGPoint(x: 0, y: 0), to: self.postTableView)
        let indexPath = self.postTableView.indexPathForRow(at: buttonPosition)
        let cell = self.postTableView.cellForRow(at: indexPath!) as? testPostCell
        let post = postsArray[indexPath!.row]
        
        self.playButton = sender
             playButton!.isHidden = true
        self.activityIndicator = cell?.showcaseImageView.subviews[1] as? UIActivityIndicatorView
        self.activityIndicator!.startAnimating()
        
        let url = NSURL(string: post.showcaseUrl!)
        player = AVPlayer(url: url! as URL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.videoGravity = AVLayerVideoGravityResize
        playerLayer!.masksToBounds = true
        
        cell!.showcaseImageView.layer.addSublayer(playerLayer!)
        playerLayer!.frame = cell!.showcaseImageView.bounds
        player!.play()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
    }
    
    func playerDidFinishPlaying(note: NSNotification){
        DispatchQueue.main.async {
            self.player!.pause()
            self.playerLayer!.removeFromSuperlayer()
        }
        self.playButton!.isHidden = false
        self.activityIndicator!.isHidden = true
    }

}//end class


extension PostsVC:UITableViewDelegate, UITableViewDataSource{
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let customCell:testPostCell = cell as! testPostCell
            customCell.backgroundColor = UIColor.clear
        if !preventAnimation.contains(indexPath as NSIndexPath){
            preventAnimation.insert(indexPath as NSIndexPath)
            TipInCellAnimator.animate(cell: customCell)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath as IndexPath) as! testPostCell
        let post = postsArray[indexPath.row]
            cell.userPost = post
            cell.postViewController = self
        
        if let mediaType = post.mediaType{
            switch mediaType{
                case "VIDEO":
                    cell.showcaseImageView.isHidden = false
                    if cell.showcaseImageView.subviews.count == 0{
                        cell.setupVideoPostCell(cell: cell)
                    }
                case "PHOTO":
                    if cell.showcaseImageView.subviews.count > 0{
                        for view in (cell.showcaseImageView.subviews){
                            view.removeFromSuperview()
                        }
                    }
                default:
                    if cell.showcaseImageView.subviews.count > 0{
                        for view in (cell.showcaseImageView.subviews){
                            view.removeFromSuperview()
                        }
                }                
            }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = postsArray[indexPath.row]
        if post.showcaseUrl == nil{
            return 175
        }else{
            return tableView.estimatedRowHeight
        }
    }
}//end extension


extension PostsVC{
    func uploadToFirebaseStorageUsingSelectedMedia(image: UIImage?, video: NSURL?, completion: @escaping (_ imageUrl: String) -> ()){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let imageName = NSUUID().uuidString
        
        if let picture = image{
            let ref = FIRStorage.storage().reference().child("post_images").child(uid).child("photos").child(imageName)
            if let uploadData = UIImageJPEGRepresentation(picture, 0.2){
                let metadata = FIRStorageMetadata()
                    metadata.contentType = "image/jpg"
                let uploadTask = ref.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                    
                    if let imageUrl = metadata?.downloadURL()?.absoluteString{
                        completion(imageUrl)
                    }
                })
                uploadTask.observe(.progress) { (snapshot) in
                    if let completedUnitCount = snapshot.progress?.completedUnitCount{
                        self.setupNavBarWithUserOrProgress(progress: String(completedUnitCount))
                    }
                }
                
                uploadTask.observe(.success) { (snapshot) in
                    self.setupNavBarWithUserOrProgress(progress: nil)
                    
                    //self.handleReloadPosts()
                }
            }
            
        } else if let movie = video {
            
            let ref = FIRStorage.storage().reference().child("post_images").child(uid).child("videos").child(imageName)
            if let uploadData = NSData(contentsOf: movie as URL){
                let metadata = FIRStorageMetadata()
                    metadata.contentType = "video/mp4"
                let uploadTask = ref.put(uploadData as Data, metadata: metadata, completion: { (metadata, error) in
                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                    
                    if let videoUrl = metadata?.downloadURL()?.absoluteString{
                        if let thumbnailImage = self.thumbnailImageForVideoUrl(videoUrl: movie){
                            self.uploadToFirebaseStorageUsingSelectedMedia(image: thumbnailImage, video: nil, completion: { (imageUrl) in
                                imageCache.setObject(thumbnailImage, forKey: videoUrl as NSString)
                                self.enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl(metadata: metadata!.contentType!, postText: self.postedText, thumbnailURL: imageUrl, fileURL: videoUrl)
                                
                            })
                        }
                    }
                })
                
                uploadTask.observe(.progress) { (snapshot) in
                    if let completedUnitCount = snapshot.progress?.completedUnitCount{
                        self.setupNavBarWithUserOrProgress(progress: String(completedUnitCount))
                    }
                }
                
                uploadTask.observe(.success) { (snapshot) in
                    self.setupNavBarWithUserOrProgress(progress: nil)
                    
                    //self.handleReloadPosts()
                }
            }
        }
    }
    
    func enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl(metadata: String, postText: String?, thumbnailURL: String?, fileURL: String?){
        guard let uid = FIRAuth.auth()?.currentUser!.uid else { return }
        let toRoom = parentRoom?.postKey
        let itemRef = DataService.ds.REF_POSTS.childByAutoId()
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        var messageItem: Dictionary<String,AnyObject>
        
        if metadata == "video/mp4"{
            messageItem = ["fromId": uid as AnyObject,
                           "timestamp" : timestamp as AnyObject,
                           "toRoom": toRoom! as AnyObject,
                           "mediaType": "VIDEO" as AnyObject,
                           "thumbnailUrl": thumbnailURL! as AnyObject,
                           "likes": 0 as AnyObject,
                           "comments": 0 as AnyObject,
                           "showcaseUrl": fileURL! as AnyObject,
                           "authorName": CurrentUser._userName as AnyObject,
                           "authorPic": CurrentUser._profileImageUrl as AnyObject
            ]
        }else if metadata == "image/jpg"{
            messageItem = ["fromId": uid as AnyObject,
                           "timestamp" : timestamp as AnyObject,
                           "toRoom": toRoom! as AnyObject,
                           "mediaType": "PHOTO" as AnyObject,
                           "likes": 0 as AnyObject,
                           "comments": 0 as AnyObject,
                           "showcaseUrl": fileURL! as AnyObject,
                           "authorName": CurrentUser._userName as AnyObject,
                           "authorPic": CurrentUser._profileImageUrl as AnyObject
            ]
        }else{
            messageItem = ["fromId": uid as AnyObject,
                           "timestamp" : timestamp as AnyObject,
                           "toRoom": toRoom! as AnyObject,
                           "mediaType": "TEXT" as AnyObject,
                           "likes": 0 as AnyObject,
                           "comments": 0 as AnyObject,
                           "authorName": CurrentUser._userName as AnyObject,
                           "authorPic": CurrentUser._profileImageUrl as AnyObject
            ]
        }
        
        if let unwrappedText = postText{
            messageItem["postText"] = unwrappedText as AnyObject
        }
        
        
        itemRef.updateChildValues(messageItem) { (error, ref) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            let postRoomRef = DataService.ds.REF_BASE.child("posts_per_room").child(self.parentRoom!.postKey!)
            
            let postID = itemRef.key
                postRoomRef.updateChildValues([postID: 1])
        }
        
        self.postTextField.text = ""
        self.postTextField.endEditing(true)
        self.imageSelectorView.image = UIImage(named: "cameraIcon")
        self.postedImage = nil
        self.postedVideo = nil
        self.postedText = nil
        self.postButton.isUserInteractionEnabled = false
        self.postButton.alpha = 0.5
        adjustPostsNumberOfParentRoom()
        handleReloadPosts()
        
    }
    
    func adjustPostsNumberOfParentRoom(){
        let intComments = Int((parentRoom?.posts)!) + 1
        let adjustedComments = NSNumber(value: Int32(intComments))
        parentRoom!.roomRef.child("posts").setValue(adjustedComments)
    }
    
    private func thumbnailImageForVideoUrl(videoUrl: NSURL) -> UIImage?{
        print(videoUrl)
        let asset = AVAsset(url: videoUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do{
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
        }catch let err{
            print(err)
        }
        return nil
    }
    
 }//end extension

extension PostsVC: UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == postTextField
        {
            let oldStr = postTextField.text! as NSString
            let newStr = oldStr.replacingCharacters(in: range, with: string) as NSString
            if newStr.length == 0
            {
                postButton.isUserInteractionEnabled = false
            }else
            {
                postButton.isUserInteractionEnabled = true
                postButton.alpha = 1.0
            }
        }
        return true
    }
}








