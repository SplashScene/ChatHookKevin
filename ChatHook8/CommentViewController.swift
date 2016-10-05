//
//  CommentViewController.swift
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


class CommentViewController: UIViewController{
    var profileView: ProfileViewController?
    var postsController: PostsVC?
    var postForComment: UserPost?
    var cellID = "cellID"
    var postedText: String?
    var timer: Timer?
    var navBar: UINavigationBar = UINavigationBar()
    var commentsArray = [Comment]()
    var postViewBottomAnchor: NSLayoutConstraint?
    
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
    
    lazy var commmentButton: MaterialButton = {
        let pb = MaterialButton()
            pb.translatesAutoresizingMaskIntoConstraints = false
            pb.setTitle("Comment", for: .normal)
            pb.addTarget(self, action: #selector(CommentViewController.handleCommentButtonTapped), for: .touchUpInside)
        return pb
    }()
    
     let postView: UIView = {
        let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.clear
        return view
    }()
    
    let postedForComment: CommentPostView = {
        let view = CommentPostView()
            view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.addSubview(topView)
        view.addSubview(postView)
        postedForComment.userPost = postForComment
        postView.addSubview(postedForComment)
        view.addSubview(postTableView)
        title = "Post Comments"
        
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.register(CommentViewCell.self, forCellReuseIdentifier: "cellID")

//        postTextField.delegate = self
        
        setupTopView()
        setupPostView()
        setupPostTableView()
//        setupNavBarWithUserOrProgress(progress: nil)
        observeComments()
        print("The post ref for this bad boy is: \(postForComment?.postRef)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Setup Methods

    func setupTopView(){
        //need x, y, width and height constraints
        topView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: view.topAnchor, constant: 72).isActive = true
        topView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        topView.addSubview(postTextField)
        topView.addSubview(commmentButton)
        
        postTextField.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 8).isActive = true
        postTextField.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        postTextField.widthAnchor.constraint(equalToConstant: 255).isActive = true
        postTextField.heightAnchor.constraint(equalTo: topView.heightAnchor, constant: -16).isActive = true
        
        commmentButton.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -8).isActive = true
        commmentButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        commmentButton.widthAnchor.constraint(equalToConstant: 85).isActive = true
        commmentButton.heightAnchor.constraint(equalTo: topView.heightAnchor, constant: -16).isActive = true
    }
    
    func setupPostView(){
        postView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        postView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        postView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            if postForComment?.showcaseUrl == nil {
                postView.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            }else{
                postView.heightAnchor.constraint(equalToConstant: 350).isActive = true
            }
        postedForComment.centerXAnchor.constraint(equalTo: postView.centerXAnchor).isActive = true
        postedForComment.centerYAnchor.constraint(equalTo: postView.centerYAnchor).isActive = true
        postedForComment.widthAnchor.constraint(equalTo: postView.widthAnchor, constant: -16).isActive = true
        postedForComment.heightAnchor.constraint(equalTo: postView.heightAnchor, constant: -16).isActive = true
    }
    
    func setupPostTableView(){
        postTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        postTableView.topAnchor.constraint(equalTo: postView.bottomAnchor).isActive = true
        postTableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16).isActive = true
        postTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
    }
    
    //MARK: - Handler Methods
    func handleCommentButtonTapped(){
        let commentRef = DataService.ds.REF_USERS_COMMENTS.childByAutoId()
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
            if let toPost = postForComment?.postKey,
               let postedComment = self.postTextField.text, postedComment != "" {
        
                    let commentItem:[String:AnyObject] =
                            ["fromId": CurrentUser._postKey as AnyObject,
                             "commentText": postedComment as AnyObject,
                             "timestamp": timestamp as AnyObject,
                             "toPost": toPost as AnyObject,
                             "likes": 0 as AnyObject,
                             "authorPic": CurrentUser._profileImageUrl as AnyObject,
                             "authorName": CurrentUser._userName as AnyObject]
                    
                    commentRef.updateChildValues(commentItem) { (error, ref) in
                        if error != nil { print(error?.localizedDescription); return }
                        
                        let postCommentRef = DataService.ds.REF_BASE.child("post_comments").child(toPost)
                        let commentID = commentRef.key
                        postCommentRef.updateChildValues([commentID: 1])
                    }
            }
        self.postTextField.text = ""
        self.postTextField.endEditing(true)
        adjustComments()
        handleReloadPosts()
    }
    
    func handleBack(){
        dismiss(animated: true, completion: nil)
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
    
    func adjustComments(){
        let intComments = Int((postForComment?.comments)!) + 1
        let adjustedComments = NSNumber(value: Int32(intComments))
        postForComment!.postRef.child("comments").setValue(adjustedComments)
    }
    
//    func handleProfile(profileView: UIView){
//        let profileViewPosition = profileView.convert(CGPoint(x: 0, y: 0), to: self.postTableView)
//        if let indexPath = self.postTableView.indexPathForRow(at: profileViewPosition){
//            let userPost = commeArray[indexPath.row]
//            let ref = DataService.ds.REF_USERS.child(userPost.fromId!)
//            
//            ref.observeSingleEvent(of: .value, with: { (snapshot) in
//                guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
//                let user = User(postKey: snapshot.key, dictionary: dictionary)
//                self.showProfileControllerForUser(user: user)
//                }, withCancel: nil)
//        }
//    }
    
    //MARK: - Observe Methods
    
    func observeComments(){
        guard let postID = postForComment?.postKey else { return }
        let commentPostsRef = DataService.ds.REF_POST_COMMENTS.child(postID)
        
        commentPostsRef.observe(.value, with: {snapshot in
            self.commentsArray = []
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        let commentKey = snap.key
                        let userCommentRef = DataService.ds.REF_USERS_COMMENTS.child(commentKey)
                        userCommentRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                if let commentDict = snapshot.value as? [String: AnyObject]{
                                    let comment = Comment(key: snapshot.key)
                                        comment.setValuesForKeys(commentDict)
                                    self.commentsArray.append(comment)
                                    
                                    self.timer?.invalidate()
                                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadPosts), userInfo: nil, repeats: false)
                                }
                            }, withCancel: nil)
                    }
                }       
        })
    }
    
    func showProfileControllerForUser(user: User){
        let profileController = ProfileViewController()
        profileController.selectedUser = user
        
        let navController = UINavigationController(rootViewController: profileController)
        present(navController, animated: true, completion: nil)
    }
    
}//end class

extension CommentViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let customCell:CommentViewCell = cell as! CommentViewCell
            customCell.backgroundColor = UIColor.clear
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath as IndexPath) as! CommentViewCell
        let comment = commentsArray[indexPath.row]
            cell.userComment = comment
//        let cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
//            cell.textLabel?.text = "Sample Cell"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}//end extension


//extension CommentViewController{
//    
//    func enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl(metadata: String, postText: String?, thumbnailURL: String?, fileURL: String?){
//        guard let uid = FIRAuth.auth()?.currentUser!.uid else { return }
//        let toRoom = parentRoom?.postKey
//        let itemRef = DataService.ds.REF_POSTS.childByAutoId()
//        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
//        var messageItem: Dictionary<String,AnyObject>
//        
//
//            messageItem = ["fromId": uid as AnyObject,
//                           "timestamp" : timestamp as AnyObject,
//                           "toRoom": toRoom! as AnyObject,
//                           "mediaType": "TEXT" as AnyObject,
//                           "likes": 0 as AnyObject,
//                           "authorName": CurrentUser._userName as AnyObject,
//                           "authorPic": CurrentUser._profileImageUrl as AnyObject]
//        
//        
//        
//        if let unwrappedText = postText{
//            messageItem["postText"] = unwrappedText as AnyObject
//        }
//        
//        
//        itemRef.updateChildValues(messageItem) { (error, ref) in
//            if error != nil {
//                print(error?.localizedDescription)
//                return
//            }
//            
//            let postRoomRef = DataService.ds.REF_BASE.child("posts_per_room").child(self.parentRoom!.postKey!)
//            
//            let postID = itemRef.key
//            postRoomRef.updateChildValues([postID: 1])
//        }
//        
//        self.postTextField.text = ""
//        self.postedImage = nil
//        self.postedVideo = nil
//        self.postedText = nil
//        self.postButton.isUserInteractionEnabled = false
//        self.postButton.alpha = 0.5
//        
//        handleReloadPosts()
//        
//    }
//}//end extension

//extension CommentViewController: UITextFieldDelegate{
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == postTextField
//        {
//            let oldStr = postTextField.text! as NSString
//            let newStr = oldStr.replacingCharacters(in: range, with: string) as NSString
//            if newStr.length == 0
//            {
//                commmentButton.isUserInteractionEnabled = false
//            }else
//            {
//                commmentButton.isUserInteractionEnabled = true
//                commmentButton.alpha = 1.0
//            }
//        }
//        return true
//    }
//}








