//
//  FeedCell.swift
//  ChatHook8
//
//  Created by Kevin Farm on 10/18/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase


    class FeedCell: UICollectionViewCell {
        var postViewController:FeedVC?
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
                        
                        self.statusTextView.text = dictionary["postText"] as? String
                        
                        if let numberOfLikes = dictionary["likes"] as? Int,
                            let numberOfComments = dictionary["comments"] as? Int{
                            
                            if numberOfLikes == 1 && numberOfComments == 1{
                                self.likesCommentsLabel.text = "\(numberOfLikes) Like • \(numberOfComments) Comment"
                            } else if numberOfLikes > 1 && numberOfComments == 1{
                                self.likesCommentsLabel.text = "\(numberOfLikes) Likes • \(numberOfComments) Comment"
                            } else if numberOfLikes == 1 && numberOfComments > 1{
                                self.likesCommentsLabel.text = "\(numberOfLikes) Like • \(numberOfComments) Comments"
                            } else {
                                self.likesCommentsLabel.text = "\(numberOfLikes) Likes • \(numberOfComments) Comments"
                            }
                        }
                        
                        
                        if let profileImageUrl = dictionary["authorPic"] as? String {
                            self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                        }
                        
                        if let postType = dictionary["mediaType"] as? String{
                            switch postType{
                            case "VIDEO":
                                guard let videoThumbnail = dictionary["thumbnailUrl"] as? String else { return }
                                self.statusImageView.loadImageUsingCacheWithUrlString(urlString: videoThumbnail)
                                self.setupVideoPostCell()
                            case "PHOTO":
                                guard let picImage = dictionary["showcaseUrl"] as? String else { return }
                                self.statusImageView.loadImageUsingCacheWithUrlString(urlString: picImage)
                                if self.statusImageView.subviews.count > 0{
                                    for view in (self.statusImageView.subviews){
                                        view.removeFromSuperview()
                                    }
                                }
                            default:
                                self.statusImageView.image = nil
                                self.statusImageView.isUserInteractionEnabled = false
                                if self.statusImageView.subviews.count > 0{
                                    for view in (self.statusImageView.subviews){
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

        
        
        let profileImageView: UIImageView = {
            let image = UIImage(named: "profile")
            let imageView = UIImageView()
                imageView.image = image
                imageView.layer.cornerRadius = 8
                imageView.layer.masksToBounds = true
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints =  false
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

        
        let statusTextView: UITextView = {
            let textView = UITextView()
                textView.translatesAutoresizingMaskIntoConstraints = false
                textView.text = "Meanwhile, the dog has a martini"
                textView.font = UIFont.systemFont(ofSize: 14)
                textView.textColor = UIColor.darkGray
                textView.sizeToFit()
            return textView
        }()
        
        lazy var statusImageView: UIImageView = {
            let imageView = UIImageView()
                imageView.layer.cornerRadius = 8
                imageView.layer.masksToBounds = true
                imageView.layer.shadowOpacity = 0.8
                imageView.layer.shadowRadius = 5.0
                imageView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
                imageView.layer.shadowColor = UIColor.black.cgColor
                imageView.contentMode = .scaleAspectFill
                imageView.translatesAutoresizingMaskIntoConstraints =  false
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoom)))
            return imageView
        }()
        
        let likesCommentsLabel: UILabel = {
            let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = "400 Likes • 10.7K Comments"
                label.font = UIFont.systemFont(ofSize: 12)
                label.textColor = UIColor.lightGray
                label.sizeToFit()
            return label
        }()
        
        let dividerLineView: UIView = {
            let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1)
            return view
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
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
            likeButton1.addTarget(self, action: #selector(handleLikeButtonTapped), for: .touchUpInside)
            commentButton.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
            shareButton.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
            deleteButton.addTarget(self, action: #selector(handlePostDelete), for: .touchUpInside)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupViews(){
            backgroundColor = UIColor.white
            addSubview(profileImageView)
            addSubview(userNameLabel)
            addSubview(statusTextView)
            addSubview(statusImageView)
            addSubview(likesCommentsLabel)
            addSubview(dividerLineView)
            addSubview(likeButton1)
            addSubview(commentButton)
            addSubview(shareButton)

            
            profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
            profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
            profileImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
            profileImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            userNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
            userNameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
            
            
            statusTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
            statusTextView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
            statusTextView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -16).isActive = true
            statusTextView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            
            statusImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            statusImageView.topAnchor.constraint(equalTo: statusTextView.bottomAnchor, constant: 8).isActive = true
            statusImageView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -16).isActive = true
            statusImageView.heightAnchor.constraint(equalToConstant: 225).isActive = true
            
            likesCommentsLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
            likesCommentsLabel.topAnchor.constraint(equalTo: statusImageView.bottomAnchor, constant: 8).isActive = true
            
            setupCommentSection()
            
        }
        
        func setupCommentSection(){
            dividerLineView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            dividerLineView.topAnchor.constraint(equalTo: likesCommentsLabel.bottomAnchor, constant: 8).isActive = true
            dividerLineView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -16).isActive = true
            dividerLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            likeButton1.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
            likeButton1.topAnchor.constraint(equalTo: dividerLineView.bottomAnchor, constant: 4).isActive = true
            likeButton1.widthAnchor.constraint(equalToConstant: 60).isActive = true
            likeButton1.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            commentButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            commentButton.topAnchor.constraint(equalTo: dividerLineView.bottomAnchor, constant: 4).isActive = true
            commentButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            commentButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            shareButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
            shareButton.topAnchor.constraint(equalTo: dividerLineView.bottomAnchor, constant: 4).isActive = true
            shareButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
            shareButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
        
        func setupVideoPostCell(){
            let playButton = PlayButton()
                playButton.addTarget(self, action: #selector(self.handlePostVideoPlay), for: .touchUpInside)
            
            self.statusImageView.addSubview(playButton)
            
            playButton.centerXAnchor.constraint(equalTo: self.statusImageView.centerXAnchor).isActive = true
            playButton.centerYAnchor.constraint(equalTo: self.statusImageView.centerYAnchor).isActive = true
            playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.hidesWhenStopped = true
            
            self.statusImageView.addSubview(activityIndicatorView)
            
            activityIndicatorView.centerXAnchor.constraint(equalTo: self.statusImageView.centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: self.statusImageView.centerYAnchor).isActive = true
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
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
            print("Inside handleZoom - VIEW")
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



