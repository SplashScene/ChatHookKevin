//
//  UserCell.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/22/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    var message: Message?{
        didSet{
            setupNameAndProfileImage()
            if message?.text != nil{
               detailTextLabel?.text = message?.text
            }else{
                if message?.mediaType == "PHOTO"{
                    detailTextLabel?.text = "Photo sent"
                }else if message?.mediaType == "VIDEO"{
                    detailTextLabel?.text = "Video sent"
                }
            }
            
            
                if let seconds = message?.timestamp?.doubleValue{
                    let timestampDate = NSDate(timeIntervalSince1970: seconds)
                    let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM d, hh:mm a"
                        //dateFormatter.dateFormat = "hh:mm:ss a"
                    timeLabel.text = dateFormatter.string(from: timestampDate as Date)
                }
        }
    }
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
            imageView.image = UIImage(named: "profileToon.jpg")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 24
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor.lightGray
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .right
            label.sizeToFit()
        return label
    }()
    
    let onlineLabel: UILabel = {
        let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = UIColor.lightGray
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .right
            label.sizeToFit()
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(onlineLabel)
        layoutUserCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 72, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        detailTextLabel?.textColor = UIColor.lightGray
    }

    func layoutUserCell(){
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
        
        onlineLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        onlineLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4).isActive = true
    }
    
    private func setupNameAndProfileImage(){
        if let id = message?.chatPartnerID(){
            checkIfUserIsOnline()
            let ref = DataService.ds.REF_USERS.child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    self.textLabel?.text = dictionary["UserName"] as? String
                    if let profileImageUrl = dictionary["ProfileImage"] as? String{
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    func checkIfUserIsOnline(){
        let searchLat = Int(CurrentUser._location.coordinate.latitude)
        let searchLong = Int(CurrentUser._location.coordinate.longitude)
        let onlineRef = DataService.ds.REF_USERSONLINE.child("\(searchLat)").child("\(searchLong)")
        
        onlineRef.observeSingleEvent(of: .value, with: { snapshot in
            if let _ = snapshot.value as? NSNull{
                self.onlineLabel.text = "Offline"
                self.onlineLabel.textColor = UIColor.red
            }else{
                self.onlineLabel.text = "Online"
                self.onlineLabel.textColor = UIColor.green
            }
        })
    }

}
