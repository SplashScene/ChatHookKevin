//
//  CommentViewCell.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/24/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase

class CommentViewCell: UITableViewCell {
    var postViewController:PostsVC?
    var likeRef: FIRDatabaseReference!
    
    var userComment: Comment?{
        didSet{
            self.profileImageView.loadImageUsingCacheWithUrlString(urlString: (userComment?.authorPic!)!)
            self.userNameLabel.text = userComment?.authorName
            self.descriptionText.text = userComment?.commentText
        }
    }
    
    var postLiked: Bool = false
    
    let cellContainerView: MaterialView = {
        let containerView = MaterialView()
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
        let imageView = MaterialImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            imageView.translatesAutoresizingMaskIntoConstraints = false
//            imageView.layer.cornerRadius = 30
//            imageView.layer.masksToBounds = true
//            imageView.contentMode = .scaleAspectFill
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
        //likeBtn.addTarget(self, action: #selector(handleLikeButtonTapped), for: .touchUpInside)
        return likeBtn
    }()
    
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
    
    //MARK: - Init Methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(cellContainerView)
        setupCellContainerView()
        
//        setupCommentContainerView()
//        //need x, y, width, height anchors
//        setupProfileImageUserNameLikes()
//        setupDescriptionTextShowcaseImage()
//        setupCommentSection()
    }
    
    //MARK: - Setup Methods
    
    func setupCellContainerView(){
        cellContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        cellContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        cellContainerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        cellContainerView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -4).isActive = true
        
        cellContainerView.addSubview(profileImageView)
        cellContainerView.addSubview(userNameLabel)
        cellContainerView.addSubview(descriptionText)
        
        profileImageView.leftAnchor.constraint(equalTo: cellContainerView.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: cellContainerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        userNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: cellContainerView.topAnchor, constant: 8).isActive = true
        
        descriptionText.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true

        descriptionText.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: -16).isActive = true
        descriptionText.rightAnchor.constraint(equalTo: cellContainerView.rightAnchor, constant: -8).isActive = true
        descriptionText.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        
        
        //cellContainerView.addSubview(profilePictureUserNameContainerView)
//        profilePictureUserNameContainerView.addSubview(profileImageView)
//        profilePictureUserNameContainerView.addSubview(userNameLabel)
//
//        profilePictureUserNameContainerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
//        profilePictureUserNameContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
//        profilePictureUserNameContainerView.widthAnchor.constraint(equalToConstant: 235).isActive = true
//        profilePictureUserNameContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        profileImageView.leftAnchor.constraint(equalTo: profilePictureUserNameContainerView.leftAnchor).isActive = true
//        profileImageView.topAnchor.constraint(equalTo: profilePictureUserNameContainerView.topAnchor).isActive = true
//        profileImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
//        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
//        
//        userNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
//        userNameLabel.centerYAnchor.constraint(equalTo: profilePictureUserNameContainerView.centerYAnchor).isActive = true
//        
//        descriptionText.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        descriptionText.topAnchor.constraint(equalTo: profilePictureUserNameContainerView.bottomAnchor, constant: -8).isActive = true
//        descriptionText.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -16).isActive = true
//        descriptionText.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
    }
    
    func handleProfileViewTapped(tapGesture: UITapGestureRecognizer){
        postViewController?.handleProfile(profileView: tapGesture.view!)
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


