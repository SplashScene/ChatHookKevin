//
//  DataService.swift
//  driveby_Showcase
//
//  Created by Kevin Farm on 4/12/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = FIRDatabase.database().reference()

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = URL_BASE
    private var _REF_POSTS = URL_BASE.child("posts")
    private var _REF_USERS = URL_BASE.child("users")
    private var _REF_MESSAGES = URL_BASE.child("messages")
    private var _REF_CHATROOMS = URL_BASE.child("publicchatrooms")
    private var _REF_USERMESSAGES = URL_BASE.child("user_messages")
    private var _REF_POSTSPERROOM = URL_BASE.child("posts_per_room")
    private var _REF_USERSONLINE = URL_BASE.child("users_online")
    private var _REF_GALLERYIMAGES = URL_BASE.child("gallery_images")
    private var _REF_USERS_GALLERY = URL_BASE.child("users_gallery")
    private var _REF_USERS_COMMENTS = URL_BASE.child("users_comments")
    private var _REF_POST_COMMENTS = URL_BASE.child("post_comments")
    
    var REF_BASE: FIRDatabaseReference{ return _REF_BASE }
    var REF_POSTS: FIRDatabaseReference{ return _REF_POSTS }
    var REF_USERS: FIRDatabaseReference{ return _REF_USERS }
    var REF_MESSAGES: FIRDatabaseReference{ return _REF_MESSAGES }
    var REF_CHATROOMS: FIRDatabaseReference{ return _REF_CHATROOMS }
    var REF_USERMESSAGES: FIRDatabaseReference { return _REF_USERMESSAGES }
    var REF_POSTSPERROOM: FIRDatabaseReference { return _REF_POSTSPERROOM }
    var REF_USERSONLINE: FIRDatabaseReference { return _REF_USERSONLINE }
    var REF_GALLERYIMAGES: FIRDatabaseReference { return _REF_GALLERYIMAGES }
    var REF_USERS_GALLERY: FIRDatabaseReference { return _REF_USERS_GALLERY }
    var REF_USERS_COMMENTS: FIRDatabaseReference { return _REF_USERS_COMMENTS}
    var REF_POST_COMMENTS: FIRDatabaseReference { return _REF_POST_COMMENTS}

    var REF_USER_CURRENT: FIRDatabaseReference{
        let uid = UserDefaults.standard.value(forKey: KEY_UID) as! String
        let user = URL_BASE.child("users").child(uid)
        return user
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, AnyObject>){
        REF_USERS.child(uid).setValue(user)
    }
    
}
