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
                        self.descriptionText.text = dictionary["postText"] as? String
                        
                        if let numberOfLikes = dictionary["likes"] as? Int{
                            self.likeCount.text = String(numberOfLikes)
                            self.likesLabel.text = numberOfLikes == 1 ? "Like" : "Likes"
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

            
            
            
//            if let seconds = userPost?.timestamp?.doubleValue{
//                let timestampDate = NSDate(timeIntervalSince1970: seconds)
//                let dateFormatter = NSDateFormatter()
//                    dateFormatter.dateFormat = "hh:mm:ss a"
//                timeLabel.text = dateFormatter.stringFromDate(timestampDate)
//            }
            
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
            label.font = UIFont(name: "Avenir Medium", size:  18.0)
            label.backgroundColor = UIColor.clear
            label.textColor = UIColor.blue
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

    
//    lazy var likeImageView: UIImageView = {
//        let imageView = UIImageView()
//            imageView.image = UIImage(named: "Like")
//            imageView.translatesAutoresizingMaskIntoConstraints = false
//            imageView.contentMode = .scaleAspectFill
//            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(likeTapped)))
//            imageView.isUserInteractionEnabled = true
//        
//        return imageView
//    }()

    let timeLabel: UILabel = {
        let label = UILabel()
            label.text = "HH:MM:SS"
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor.lightGray
            label.translatesAutoresizingMaskIntoConstraints = false
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
//            label.text = "Likes"
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

    
    /*
    let descriptionText: UITextView = {
        let descripTextView = UITextView()
            descripTextView.translatesAutoresizingMaskIntoConstraints = false
            descripTextView.text = "This is sample description text for the post"
            descripTextView.font = UIFont(name: "Avenir Medium", size:  14.0)
            descripTextView.textColor = UIColor.darkGrayColor()
            descripTextView.editable = false
            descripTextView.scrollEnabled = false
//        let fixedWidth = descripTextView.frame.size.width
//        descripTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//        let newSize = descripTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//        var newFrame = descripTextView.frame
//        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//        descripTextView.frame = newFrame;
            //descripTextView.sizeToFit()
        return descripTextView
    }()
    */
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

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        //self.layoutIfNeeded()
        //descriptionText.delegate = self
        
        cellContainerView.addSubview(profileImageView)
        cellContainerView.addSubview(userNameLabel)
        cellContainerView.addSubview(likeButton)
        //cellContainerView.addSubview(likeImageView)
        cellContainerView.addSubview(likeCount)
        cellContainerView.addSubview(likesLabel)
        cellContainerView.addSubview(descriptionText)
        cellContainerView.addSubview(showcaseImageView)
        cellContainerView.addSubview(separatorLineView)
        
        //need x, y, width, height anchors
        setupProfileImageUserNameLikes()
        setupDescriptionTextShowcaseImage()
        
            }
    
    func setupProfileImageUserNameLikes(){
        profileImageView.leftAnchor.constraint(equalTo: cellContainerView.leftAnchor, constant: 8).isActive = true
        profileImageView.topAnchor.constraint(equalTo: cellContainerView.topAnchor, constant: 8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        userNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        userNameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        
        //        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        //        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        //        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //        timeLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
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
        descriptionText.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        descriptionText.widthAnchor.constraint(equalTo: cellContainerView.widthAnchor, constant: -16).isActive = true
        descriptionText.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
        showcaseImageView.centerXAnchor.constraint(equalTo: cellContainerView.centerXAnchor).isActive = true
        showcaseImageView.topAnchor.constraint(equalTo: descriptionText.bottomAnchor, constant: 8).isActive = true
        showcaseImageView.widthAnchor.constraint(equalTo: cellContainerView.widthAnchor, constant: -16).isActive = true
        showcaseImageView.bottomAnchor.constraint(equalTo: cellContainerView.bottomAnchor, constant: -28).isActive = true
        
        separatorLineView.leftAnchor.constraint(equalTo: cellContainerView.leftAnchor).isActive = true
        separatorLineView.bottomAnchor.constraint(equalTo: cellContainerView.bottomAnchor, constant: -24).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: cellContainerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        
        contentView.addSubview(cellContainerView)
        
        cellContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        cellContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        cellContainerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -16).isActive = true
        cellContainerView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -16).isActive = true

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
    
    func likeTapped(tapGesture: UITapGestureRecognizer){
        likeRef.observeSingleEvent(of: .value, with: { snapshot in
            if let _ = snapshot.value as? NSNull{
                //This means that we have not liked this specific post
                let image = UIImage(named: "iLike")
                self.likeButton.setImage(image, for: .normal)
                //self.likeImageView.image = UIImage(named: "iLike")
                self.userPost!.adjustLikes(addLike: true)
                self.likeRef.setValue(true)
                self.postViewController!.handleReloadPosts()
            }else{
                let image = UIImage(named: "Like")
                self.likeButton.setImage(image, for: .normal)
                //self.likeImageView.image = UIImage(named: "Like")
                self.userPost!.adjustLikes(addLike: false)
                self.likeRef.removeValue()
                self.postViewController!.handleReloadPosts()
            }
        })
    }
    
    func handleZoom(tapGesture: UITapGestureRecognizer){
        
        if let imageView = tapGesture.view as? UIImageView{
            postViewController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
        
    }
    
    func handlePostVideoPlay(sender: UIButton) {
        postViewController?.handlePlayPostVideo(sender: sender)
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