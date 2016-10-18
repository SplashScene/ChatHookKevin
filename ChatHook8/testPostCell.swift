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

    //MARK: - Properties
    var userPost: UserPost?{
        didSet{
                deleteButton.isHidden = CurrentUser._postKey != userPost?.fromId
                likeRef = DataService.ds.REF_USER_CURRENT.child("Likes").child(userPost!.postKey!)
                let postRef = DataService.ds.REF_POSTS.child(userPost!.postKey!)
                    postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            
                            if let seconds = self.userPost?.timestamp?.doubleValue,
                                let userName = dictionary["authorName"] as? String,
                                let cityAndState = dictionary["cityAndState"] as? String {
                                    let timestampDate = NSDate(timeIntervalSince1970: seconds)
                                    let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "MMM d, hh:mm a"
                                    let timeStamp = dateFormatter.string(from: timestampDate as Date)
                                    let attributedText = NSMutableAttributedString(string: userName, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.blue])
                                        attributedText.append(NSAttributedString(string: "\n\(timeStamp) • \(cityAndState)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.lightGray]))
                                    let paragraphStyle = NSMutableParagraphStyle()
                                        paragraphStyle.lineSpacing = 4
                                    
                                    attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.string.characters.count))
                                    
    //                                let attachment = NSTextAttachment()
    //                                    attachment.image = UIImage(named: "GlobeIcon")
    //                                    attachment.bounds = CGRect(x: 0, y: -2, width: 12, height: 12)
    //                                
    //                                attributedText.append(NSAttributedString(attachment: attachment))
                                    
                                    self.userNameLabel.attributedText = attributedText
                            }
                        
                            self.descriptionText.text = dictionary["postText"] as? String
                            
                            if let numberOfLikes = dictionary["likes"] as? Int,
                               let numberOfComments = dictionary["comments"] as? Int{
                                
                                if numberOfLikes == 1 && numberOfComments == 1{
                                    self.likesLabel.text = "\(numberOfLikes) Like • \(numberOfComments) Comment"
                                } else if numberOfLikes > 1 && numberOfComments == 1{
                                    self.likesLabel.text = "\(numberOfLikes) Likes • \(numberOfComments) Comment"
                                } else if numberOfLikes == 1 && numberOfComments > 1{
                                    self.likesLabel.text = "\(numberOfLikes) Like • \(numberOfComments) Comments"
                                } else {
                                    self.likesLabel.text = "\(numberOfLikes) Likes • \(numberOfComments) Comments"
                                }
                            }
                            
                            
                            if let profileImageUrl = dictionary["authorPic"] as? String {
                                self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                            }
                            
                            if let postType = dictionary["mediaType"] as? String{
                                switch postType{
                                    case "VIDEO":
                                        guard let videoThumbnail = dictionary["thumbnailUrl"] as? String else { return }
                                        self.showcaseImageView.loadImageUsingCacheWithUrlString(urlString: videoThumbnail)
                                        self.setupVideoPostCell()
                                    case "PHOTO":
                                        guard let picImage = dictionary["showcaseUrl"] as? String else { return }
                                        self.showcaseImageView.loadImageUsingCacheWithUrlString(urlString: picImage)
                                            if self.showcaseImageView.subviews.count > 0{
                                                for view in (self.showcaseImageView.subviews){
                                                    view.removeFromSuperview()
                                                }
                                            }
                                    default:
                                        self.showcaseImageView.image = nil
                                        self.showcaseImageView.isUserInteractionEnabled = false
                                            if self.showcaseImageView.subviews.count > 0{
                                                for view in (self.showcaseImageView.subviews){
                                                    view.removeFromSuperview()
                                                }
                                            }
                                    }
                            }
                        }
                    }, withCancel: nil)
            
                    likeRef.observeSingleEvent(of: .value, with: { snapshot in
                        if let _ = snapshot.value as? NSNull{
                            //This means that we have not liked this specific post
                            let image = UIImage(named: "meh")
                            self.likeButton1.setImage(image, for: .normal)
                            //self.likeImageView.image = UIImage(named: "Like")
                        }else{
                            let image = UIImage(named: "like")
                            self.likeButton1.setImage(image, for: .normal)
                           // self.likeImageView.image = UIImage(named: "iLike")
                        }
                    })
        }
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
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: FONT_AVENIR_MEDIUM, size:  18.0)
            label.backgroundColor = UIColor.clear
            label.sizeToFit()
        return label
    }()
    
    let likesLabel: UILabel = {
        let label = UILabel()
            label.font = UIFont(name: FONT_AVENIR_MEDIUM, size:  12.0)
            label.textColor = UIColor.lightGray
            label.translatesAutoresizingMaskIntoConstraints = false
            label.sizeToFit()
        return label
    }()
    
    let descriptionText: UITextView = {
        let descripTextView = UITextView()
            descripTextView.translatesAutoresizingMaskIntoConstraints = false
            descripTextView.font = UIFont(name: FONT_AVENIR_MEDIUM, size:  14.0)
            descripTextView.textColor = UIColor.darkGray
            descripTextView.backgroundColor = UIColor.green
            descripTextView.sizeToFit()
            descripTextView.isScrollEnabled = false
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
    
    lazy var likeButton1 = testPostCell.buttonForTitle(title: "Like", imageName: "meh")
    lazy var commentButton = testPostCell.buttonForTitle(title: "Comment", imageName: "commenticon_small")
    lazy var shareButton = testPostCell.buttonForTitle(title: "Share", imageName: "share")
    lazy var deleteButton = testPostCell.buttonForTitle(title: nil, imageName: "deleteIcon40")
    
    static func buttonForTitle(title: String?, imageName: String) -> UIButton{
        let image = UIImage(named: imageName)
        let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.lightGray, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            button.setImage(image, for: .normal)
        return button
    }
    //MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupCellContainerView()
        setupProfileImageUserNameLikes()
        setupDescriptionTextShowcaseImage()
        setupCommentSection()
        likeButton1.addTarget(self, action: #selector(handleLikeButtonTapped), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(handlePostDelete), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Setup Methods
    func setupCellContainerView(){
        cellContainerView.addSubview(profilePictureUserNameContainerView)
            profilePictureUserNameContainerView.addSubview(profileImageView)
            profilePictureUserNameContainerView.addSubview(userNameLabel)
        cellContainerView.addSubview(deleteButton)
        cellContainerView.addSubview(descriptionText)
        cellContainerView.addSubview(showcaseImageView)
        cellContainerView.addSubview(likesLabel)
        cellContainerView.addSubview(separatorLineView)
        cellContainerView.addSubview(likeButton1)
        cellContainerView.addSubview(commentButton)
        cellContainerView.addSubview(shareButton)
    }
    
    func setupProfileImageUserNameLikes(){
        print("Inside setupProfileBaboon")
        print("The userPost.fromID is: \(userPost?.fromId) and the Current User PostKey is: \(CurrentUser._postKey)")
        profilePictureUserNameContainerView.leftAnchor.constraint(equalTo: cellContainerView.leftAnchor, constant: 8).isActive = true
        profilePictureUserNameContainerView.topAnchor.constraint(equalTo: cellContainerView.topAnchor, constant: 8).isActive = true
        profilePictureUserNameContainerView.widthAnchor.constraint(equalToConstant: 235).isActive = true
        profilePictureUserNameContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: profilePictureUserNameContainerView.leftAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: profilePictureUserNameContainerView.topAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        userNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: profilePictureUserNameContainerView.topAnchor).isActive = true
        
        deleteButton.rightAnchor.constraint(equalTo: cellContainerView.rightAnchor).isActive = true
        deleteButton.topAnchor.constraint(equalTo: cellContainerView.topAnchor).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setupDescriptionTextShowcaseImage(){
        descriptionText.centerXAnchor.constraint(equalTo: cellContainerView.centerXAnchor).isActive = true
        descriptionText.topAnchor.constraint(equalTo: profilePictureUserNameContainerView.bottomAnchor).isActive = true
        descriptionText.widthAnchor.constraint(equalTo: cellContainerView.widthAnchor, constant: -16).isActive = true
//        descriptionText.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let sizeThatShouldFitTheContent = descriptionText.sizeThatFits(descriptionText.frame.size)
        print("The height of the descrip text is: \(sizeThatShouldFitTheContent.height)")
//        descriptionText.heightAnchor.constraint(equalToConstant: sizeThatShouldFitTheContent.height).isActive = true
        
//        let fixedWidth = cellContainerView.frame.size.width
//        descriptionText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        let newSize = descriptionText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        var newFrame = descriptionText.frame
//        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//        descriptionText.frame = newFrame;
        
        
        showcaseImageView.centerXAnchor.constraint(equalTo: cellContainerView.centerXAnchor).isActive = true
        showcaseImageView.topAnchor.constraint(equalTo: descriptionText.bottomAnchor, constant: 8).isActive = true
        showcaseImageView.widthAnchor.constraint(equalTo: cellContainerView.widthAnchor, constant: -16).isActive = true
        showcaseImageView.heightAnchor.constraint(equalToConstant: 205).isActive = true
        
        likesLabel.leftAnchor.constraint(equalTo: cellContainerView.leftAnchor, constant: 8).isActive = true
        likesLabel.bottomAnchor.constraint(equalTo: separatorLineView.topAnchor).isActive = true

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
        
        likeButton1.leftAnchor.constraint(equalTo: cellContainerView.leftAnchor, constant: 8).isActive = true
        likeButton1.topAnchor.constraint(equalTo: separatorLineView.bottomAnchor, constant: 4).isActive = true
        likeButton1.widthAnchor.constraint(equalToConstant: 60).isActive = true
        likeButton1.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        commentButton.centerXAnchor.constraint(equalTo: cellContainerView.centerXAnchor).isActive = true
        commentButton.topAnchor.constraint(equalTo: separatorLineView.bottomAnchor, constant: 4).isActive = true
        commentButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        commentButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        shareButton.rightAnchor.constraint(equalTo: cellContainerView.rightAnchor, constant: -8).isActive = true
        shareButton.topAnchor.constraint(equalTo: separatorLineView.bottomAnchor, constant: 4).isActive = true
        shareButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupVideoPostCell(){
        let playButton = PlayButton()
            playButton.addTarget(self, action: #selector(self.handlePostVideoPlay), for: .touchUpInside)
        
        self.showcaseImageView.addSubview(playButton)
        
        playButton.centerXAnchor.constraint(equalTo: self.showcaseImageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: self.showcaseImageView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.hidesWhenStopped = true
        
        self.showcaseImageView.addSubview(activityIndicatorView)
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: self.showcaseImageView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: self.showcaseImageView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    //MARK: - Handle Methods
    func handleLikeButtonTapped(sender: UIButton){
        likeRef.observeSingleEvent(of: .value, with: { snapshot in
            if let _ = snapshot.value as? NSNull{
                //This means that we have not liked this specific post
                self.userPost!.adjustLikes(addLike: true)
                self.likeRef.setValue(true)
                sender.tag = 1
                self.postViewController!.adjustLikesInArrayDisplay(sender: sender)
            }else{
                self.userPost!.adjustLikes(addLike: false)
                self.likeRef.removeValue()
                sender.tag = 0
                self.postViewController!.adjustLikesInArrayDisplay(sender: sender)
            }
        })
    }
    
    func handleZoom(tapGesture: UITapGestureRecognizer){
        if let imageView = tapGesture.view as? UIImageView{
            postViewController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    
    func handleShare(sender: UIButton){
        postViewController?.handleShare(sender: sender)
    }
    
    func handleProfileViewTapped(tapGesture: UITapGestureRecognizer){
        postViewController?.handleProfile(profileView: tapGesture.view!)
    }
    
    func handlePostVideoPlay(sender: UIButton) {
        postViewController?.handlePlayPostVideo(sender: sender)
    }
    
    func handleCommentTapped(sender: UIButton){
        postViewController?.handleCommentTapped(sender: sender)
    }
    
    func handlePostDelete(sender: UIButton){
        postViewController?.handleDeletePost(sender: sender)
    }
    
}

