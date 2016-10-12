//
//  testPostCell.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/24/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase

class testPostCell: UITableViewCell {
    var postViewController:PostsVC?
    var likeRef: FIRDatabaseReference!

    var userPost: UserPost?{
        didSet{
                likeRef = DataService.ds.REF_USER_CURRENT.child("Likes").child(userPost!.postKey!)
                let postRef = DataService.ds.REF_POSTS.child(userPost!.postKey!)
                    postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            
                            self.userNameLabel.text = dictionary["authorName"] as? String
                            self.cityAndStateLabel.text = dictionary["cityAndState"] as? String
                            self.descriptionText.text = dictionary["postText"] as? String
                            
                            
                            if let numberOfLikes = dictionary["likes"] as? Int{
                                self.likeCount.text = String(numberOfLikes)
                                self.likesLabel.text = numberOfLikes == 1 ? "Like" : "Likes"
                            }
                            
                            if let numberOfComments = dictionary["comments"] as? Int{
                                self.commentCount.text = String(numberOfComments)
                                self.commentLabel.text = numberOfComments == 1 ? "Comment" : "Comments"
                            }
                            
                            if let profileImageUrl = dictionary["authorPic"] as? String {
                                self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                            }
                            if let postType = dictionary["mediaType"] as? String{
                                switch postType{
                                case "VIDEO":
                                    guard let videoThumbnail = dictionary["thumbnailUrl"] as? String else { return }
                                    self.showcaseImageView.loadImageUsingCacheWithUrlString(urlString: videoThumbnail)
                                case "PHOTO":
                                    guard let picImage = dictionary["showcaseUrl"] as? String else { return }
                                    self.showcaseImageView.loadImageUsingCacheWithUrlString(urlString: picImage)
                                default:
                                    self.showcaseImageView.image = nil
                                }
                            }
                        }
                    }, withCancel: nil)
            
                    likeRef.observeSingleEvent(of: .value, with: { snapshot in
                        if let _ = snapshot.value as? NSNull{
                            //This means that we have not liked this specific post
                            let image = UIImage(named: "Like")
                            self.likeButton.setImage(image, for: .normal)
                            //self.likeImageView.image = UIImage(named: "Like")
                        }else{
                            let image = UIImage(named: "iLike")
                            self.likeButton.setImage(image, for: .normal)
                           // self.likeImageView.image = UIImage(named: "iLike")
                        }
                    })


            if let seconds = userPost?.timestamp?.doubleValue{
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d, hh:mm a"
                    //dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
            
        }
    }

    var postLiked: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let cellContainerView: UIView = {
        let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = UIColor.white
            containerView.layer.cornerRadius = 5.0
            containerView.layer.masksToBounds = true
            containerView.sizeToFit()
        return containerView
    }()
    
    lazy var profilePictureUserNameContainerView: UIView = {
        let profileNameView = UIView()
            profileNameView.translatesAutoresizingMaskIntoConstraints = false
            profileNameView.backgroundColor = UIColor.white
            profileNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(testPostCell.handleProfileViewTapped)))
        return profileNameView
    }()
    
    
    let profileImageView: MaterialImageView = {
        let imageView = MaterialImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 24
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.alpha = 1.0
            label.text = "User Name"
            label.font = UIFont(name: FONT_AVENIR_MEDIUM, size:  18.0)
            label.backgroundColor = UIColor.clear
            label.textColor = UIColor.blue
            label.sizeToFit()
        return label
    }()
    
    let cityAndStateLabel: UILabel = {
        let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: FONT_AVENIR_LIGHT, size:  14.0)
            label.backgroundColor = UIColor.clear
            label.textColor = UIColor.lightGray
            label.sizeToFit()
        return label
    }()

    
    lazy var likeButton: UIButton = {
        let likeBtn = UIButton()
        let image = UIImage(named: "Like")
            likeBtn.setImage(image, for: .normal)
            likeBtn.translatesAutoresizingMaskIntoConstraints = false
            likeBtn.addTarget(self, action: #selector(handleLikeButtonTapped), for: .touchUpInside)
        return likeBtn
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor.lightGray
            label.translatesAutoresizingMaskIntoConstraints = false
            label.sizeToFit()
        return label
    }()
    
    var likeCount: UILabel = {
        let label = UILabel()
            label.text = "0"
            label.font = UIFont(name: "Avenir Medium", size:  12.0)
            label.textColor = UIColor.darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            label.sizeToFit()
        return label
    }()

    let likesLabel: UILabel = {
        let label = UILabel()
            label.font = UIFont(name: "Avenir Medium", size:  12.0)
            label.textColor = UIColor.darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            label.sizeToFit()
        return label
    }()
    
    let descriptionText: UILabel = {
        let descripTextView = UILabel()
            descripTextView.translatesAutoresizingMaskIntoConstraints = false
            descripTextView.font = UIFont(name: "Avenir Medium", size:  14.0)
            descripTextView.textColor = UIColor.darkGray
            descripTextView.numberOfLines = 0
        return descripTextView
    }()

    lazy var showcaseImageView: UIImageView = {
        let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 5
            imageView.layer.masksToBounds = true
            imageView.layer.shadowOpacity = 0.8
            imageView.layer.shadowRadius = 5.0
            imageView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            imageView.layer.shadowColor = UIColor.black.cgColor
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoom)))
        return imageView
    }()
    
    let separatorLineView: UIView = {
        let sepLineView = UIView()
            sepLineView.translatesAutoresizingMaskIntoConstraints = false
            sepLineView.backgroundColor = UIColor.darkGray
        return sepLineView
    }()
    
    let commentContainerView: UIView = {
        let commentContainerView = UIView()
            commentContainerView.translatesAutoresizingMaskIntoConstraints = false
            commentContainerView.backgroundColor = UIColor.white
        return commentContainerView
    }()
    
    var commentCount: UILabel = {
        let label = UILabel()
            label.text = "0"
            label.font = UIFont(name: "Avenir Medium", size:  12.0)
            label.textColor = UIColor.darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            label.sizeToFit()
        return label
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
            label.text = "Comments"
            label.font = UIFont(name: "Avenir Medium", size:  12.0)
            label.textColor = UIColor.darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            label.sizeToFit()
        return label
    }()
    
    lazy var commentButtonContainerView: UIView = {
        let commentContainerView = UIView()
            commentContainerView.translatesAutoresizingMaskIntoConstraints = false
            commentContainerView.backgroundColor = UIColor.white
        commentContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCommentTapped)))
        return commentContainerView
    }()
    
    let commentImageView: UIImageView = {
        let imageView = UIImageView()
            imageView.image = UIImage(named: "commenticon_small")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let makeCommentLabel: UILabel = {
        let label = UILabel()
            label.text = "Comment"
            label.font = UIFont(name: "Avenir Medium", size:  12.0)
            label.textColor = UIColor.darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            label.sizeToFit()
        return label
    }()

    
    lazy var shareButtonContainerView: UIView = {
        let shareContainerView = UIView()
            shareContainerView.translatesAutoresizingMaskIntoConstraints = false
            shareContainerView.backgroundColor = UIColor.white
            shareContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShare)))
        return shareContainerView
    }()
    
    let shareImageView: UIImageView = {
        let imageView = UIImageView()
            imageView.image = UIImage(named: "share_music_btn")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let shareLabel: UILabel = {
        let label = UILabel()
            label.text = "Share"
            label.font = UIFont(name: "Avenir Medium", size:  12.0)
            label.textColor = UIColor.darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            label.sizeToFit()
        return label
    }()



    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupCellContainerView()
        setupCommentContainerView()
        //need x, y, width, height anchors
        setupProfileImageUserNameLikes()
        setupDescriptionTextShowcaseImage()
        setupCommentSection()
    }
    
    func setupCellContainerView(){
        cellContainerView.addSubview(profilePictureUserNameContainerView)
            profilePictureUserNameContainerView.addSubview(profileImageView)
            profilePictureUserNameContainerView.addSubview(userNameLabel)
            profilePictureUserNameContainerView.addSubview(cityAndStateLabel)
            profilePictureUserNameContainerView.addSubview(timeLabel)
        cellContainerView.addSubview(likeButton)
        cellContainerView.addSubview(likeCount)
        cellContainerView.addSubview(likesLabel)
        cellContainerView.addSubview(descriptionText)
        cellContainerView.addSubview(showcaseImageView)
        cellContainerView.addSubview(separatorLineView)
        cellContainerView.addSubview(commentContainerView)
        cellContainerView.addSubview(shareButtonContainerView)
    }
    
    func setupCommentContainerView(){
        commentContainerView.addSubview(commentCount)
        commentContainerView.addSubview(commentLabel)
        commentContainerView.addSubview(commentButtonContainerView)
        commentContainerView.addSubview(shareButtonContainerView)
        
        commentButtonContainerView.addSubview(commentImageView)
        commentButtonContainerView.addSubview(makeCommentLabel)
        
        shareButtonContainerView.addSubview(shareImageView)
        shareButtonContainerView.addSubview(shareLabel)
    }
    
    func setupProfileImageUserNameLikes(){
        profilePictureUserNameContainerView.leftAnchor.constraint(equalTo: cellContainerView.leftAnchor, constant: 8).isActive = true
        profilePictureUserNameContainerView.topAnchor.constraint(equalTo: cellContainerView.topAnchor, constant: 8).isActive = true
        profilePictureUserNameContainerView.widthAnchor.constraint(equalToConstant: 235).isActive = true
        profilePictureUserNameContainerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: profilePictureUserNameContainerView.leftAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: profilePictureUserNameContainerView.topAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        userNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: profilePictureUserNameContainerView.topAnchor).isActive = true
        
        cityAndStateLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 16).isActive = true
        cityAndStateLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: -4).isActive = true
        
        timeLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 16).isActive = true
        timeLabel.topAnchor.constraint(equalTo: cityAndStateLabel.bottomAnchor, constant: -4).isActive = true
        
        
        likeButton.rightAnchor.constraint(equalTo: likesLabel.leftAnchor, constant: -8).isActive = true
        likeButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        likeButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        likeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        likesLabel.rightAnchor.constraint(equalTo: cellContainerView.rightAnchor, constant: -16).isActive = true
        likesLabel.topAnchor.constraint(equalTo: likeButton.centerYAnchor).isActive = true
        
        likeCount.centerXAnchor.constraint(equalTo: likesLabel.centerXAnchor).isActive = true
        likeCount.bottomAnchor.constraint(equalTo: likeButton.centerYAnchor).isActive = true
    }
    
    func setupDescriptionTextShowcaseImage(){
        descriptionText.centerXAnchor.constraint(equalTo: cellContainerView.centerXAnchor).isActive = true
        descriptionText.topAnchor.constraint(equalTo: profilePictureUserNameContainerView.bottomAnchor, constant: 8).isActive = true
        descriptionText.widthAnchor.constraint(equalTo: cellContainerView.widthAnchor, constant: -16).isActive = true
        descriptionText.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
        showcaseImageView.centerXAnchor.constraint(equalTo: cellContainerView.centerXAnchor).isActive = true
        showcaseImageView.topAnchor.constraint(equalTo: descriptionText.bottomAnchor, constant: 8).isActive = true
        showcaseImageView.widthAnchor.constraint(equalTo: cellContainerView.widthAnchor, constant: -16).isActive = true
        showcaseImageView.bottomAnchor.constraint(equalTo: cellContainerView.bottomAnchor, constant: -28).isActive = true
        
        contentView.addSubview(cellContainerView)
        
        cellContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        cellContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        cellContainerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -16).isActive = true
        cellContainerView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -16).isActive = true
    }
    
    func setupCommentSection(){
        separatorLineView.leftAnchor.constraint(equalTo: cellContainerView.leftAnchor).isActive = true
        separatorLineView.bottomAnchor.constraint(equalTo: cellContainerView.bottomAnchor, constant: -24).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: cellContainerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        commentContainerView.centerXAnchor.constraint(equalTo: cellContainerView.centerXAnchor).isActive = true
        commentContainerView.bottomAnchor.constraint(equalTo: cellContainerView.bottomAnchor, constant: -4).isActive = true
        commentContainerView.widthAnchor.constraint(equalTo: cellContainerView.widthAnchor, constant: -8).isActive = true
        commentContainerView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        commentCount.leftAnchor.constraint(equalTo: commentContainerView.leftAnchor, constant: 8).isActive = true
        commentCount.centerYAnchor.constraint(equalTo: commentContainerView.centerYAnchor).isActive = true
        
        commentLabel.leftAnchor.constraint(equalTo: commentCount.rightAnchor, constant: 8).isActive = true
        commentLabel.centerYAnchor.constraint(equalTo: commentContainerView.centerYAnchor).isActive = true
        
        commentButtonContainerView.centerXAnchor.constraint(equalTo: commentContainerView.centerXAnchor).isActive = true
        commentButtonContainerView.centerYAnchor.constraint(equalTo: commentContainerView.centerYAnchor).isActive = true
        commentButtonContainerView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        commentButtonContainerView.heightAnchor.constraint(equalTo: commentContainerView.heightAnchor).isActive = true
        
        commentImageView.leftAnchor.constraint(equalTo: commentButtonContainerView.leftAnchor, constant: 3).isActive = true
        commentImageView.centerYAnchor.constraint(equalTo: commentButtonContainerView.centerYAnchor).isActive = true
        commentImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        commentImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        makeCommentLabel.rightAnchor.constraint(equalTo: commentButtonContainerView.rightAnchor, constant: -3).isActive = true
        makeCommentLabel.centerYAnchor.constraint(equalTo: commentButtonContainerView.centerYAnchor).isActive = true
        
        shareButtonContainerView.rightAnchor.constraint(equalTo: cellContainerView.rightAnchor, constant: -8).isActive = true
        shareButtonContainerView.bottomAnchor.constraint(equalTo: cellContainerView.bottomAnchor, constant: -4).isActive = true
        shareButtonContainerView.widthAnchor.constraint(equalToConstant: 56).isActive = true
        shareButtonContainerView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        shareImageView.leftAnchor.constraint(equalTo: shareButtonContainerView.leftAnchor, constant: 3).isActive = true
        shareImageView.centerYAnchor.constraint(equalTo: shareButtonContainerView.centerYAnchor).isActive = true
        shareImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        shareImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        shareLabel.rightAnchor.constraint(equalTo: shareButtonContainerView.rightAnchor, constant: -3).isActive = true
        shareLabel.centerYAnchor.constraint(equalTo: shareButtonContainerView.centerYAnchor).isActive = true

    }
    
    func handleLikeButtonTapped(sender: UIButton){
        likeRef.observeSingleEvent(of: .value, with: { snapshot in
            if let _ = snapshot.value as? NSNull{
                //This means that we have not liked this specific post
                let image = UIImage(named: "iLike")
                self.likeButton.setImage(image, for: .normal)
                self.userPost!.adjustLikes(addLike: true)
                self.likeRef.setValue(true)
                let likeBtn = sender
                    likeBtn.tag = 1
                self.postViewController!.adjustLikesInArrayDisplay(sender: likeBtn)
                //self.postViewController!.handleReloadPosts()
            }else{
                let image = UIImage(named: "Like")
                self.likeButton.setImage(image, for: .normal)
                self.userPost!.adjustLikes(addLike: false)
                self.likeRef.removeValue()
                let likeBtn = sender
                likeBtn.tag = 0
                self.postViewController!.adjustLikesInArrayDisplay(sender: likeBtn)
                //self.postViewController!.handleReloadPosts()
            }
        })
    }
    
//    func likeTapped(tapGesture: UITapGestureRecognizer){
//        likeRef.observeSingleEvent(of: .value, with: { snapshot in
//            if let _ = snapshot.value as? NSNull{
//                //This means that we have not liked this specific post
//                let image = UIImage(named: "iLike")
//                self.likeButton.setImage(image, for: .normal)
//                //self.likeImageView.image = UIImage(named: "iLike")
//                self.userPost!.adjustLikes(addLike: true)
//                self.likeRef.setValue(true)
//                self.postViewController!.handleReloadPosts()
//            }else{
//                let image = UIImage(named: "Like")
//                self.likeButton.setImage(image, for: .normal)
//                //self.likeImageView.image = UIImage(named: "Like")
//                self.userPost!.adjustLikes(addLike: false)
//                self.likeRef.removeValue()
//                self.postViewController!.handleReloadPosts()
//            }
//        })
//    }
    
    func handleZoom(tapGesture: UITapGestureRecognizer){
        if let imageView = tapGesture.view as? UIImageView{
            postViewController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    
    func handleShare(tapGesture: UITapGestureRecognizer){
            postViewController?.handleShare(shareView: tapGesture.view!)
    }
    
    func handleProfileViewTapped(tapGesture: UITapGestureRecognizer){
        postViewController?.handleProfile(profileView: tapGesture.view!)
    }
    
    func handlePostVideoPlay(sender: UIButton) {
        postViewController?.handlePlayPostVideo(sender: sender)
    }
    
    func handleCommentTapped(tapGesture: UITapGestureRecognizer){
        postViewController?.handleCommentTapped(commentView: tapGesture.view!)
    }
    
    func setupVideoPostCell(cell: testPostCell){
        
        let playButton = PlayButton()
        
        playButton.addTarget(self, action: #selector(handlePostVideoPlay), for: .touchUpInside)
        
        cell.showcaseImageView.addSubview(playButton)
        
        playButton.centerXAnchor.constraint(equalTo: cell.showcaseImageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: cell.showcaseImageView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.hidesWhenStopped = true
        
        cell.showcaseImageView.addSubview(activityIndicatorView)
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: cell.showcaseImageView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: cell.showcaseImageView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

//extension testPostCell: UITextViewDelegate{
//    func textViewDidChange(textView: UITextView) {
//        let fixedWidth = textView.frame.size.width
//        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//        var newFrame = textView.frame
//        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//        textView.frame = newFrame;
//    }
//}
