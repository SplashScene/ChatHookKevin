//
//  ChatViewController.swift
//  ChatHook
//
//  Created by Kevin Farm on 5/27/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseStorage

class ChatViewController: JSQMessagesViewController {
 
    var messages = [JSQMessage]()
    var rawMessages = [Message]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var message:JSQMessage?
    var messageImage: UIImage!
    var user: User?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var pButton: UIButton?
    var cellAIV: UIActivityIndicatorView?

    
    var userIsTypingRef: FIRDatabaseReference!
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }

    var usersTypingQuery: FIRDatabaseQuery!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBubbles()
       
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 0, height: 0)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 0, height: 0)
        collectionView!.alwaysBounceVertical = true
        automaticallyScrollsToMostRecentMessage = true
        setupNavBarWithUserOrProgress(progress: nil)
        observeMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.inputToolbar.barTintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ChatViewController.handleCancel))
    }
    
    func setupNavBarWithUserOrProgress(progress:String?){
        
        let titleView = UIView()
            titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
            profileImageView.translatesAutoresizingMaskIntoConstraints = false
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.layer.cornerRadius = 20
            profileImageView.clipsToBounds = true
            profileImageView.image = messageImage
        
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
            if let progressText = progress{
                nameLabel.text = progressText
                nameLabel.textColor = UIColor.red
            }else{
                nameLabel.text = user?.userName
                nameLabel.textColor = UIColor.darkGray
            }
        
        containerView.addSubview(nameLabel)
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
       
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleLightGray())
    }

    
//MARK: Collection Views
    //[JSQMessagesViewController collectionView:messageDataForItemAtIndexPath:]
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        return message.senderId == CurrentUser._postKey ? outgoingBubbleImageView : incomingBubbleImageView
    }
    
    func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    
    //var cell:JSQMessagesCollectionViewCell?
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath as IndexPath) as! JSQMessagesCollectionViewCell
        cell.delegate = self
        message = messages[indexPath.item]
        let rawMessage = rawMessages[indexPath.item]
        
        if rawMessage.mediaType == "VIDEO"{
            self.setupVideoCell(cell: cell, rawMessage: rawMessage)
        }
        
        cell.textView?.textColor = message!.senderId == CurrentUser._postKey ? UIColor.white : UIColor.black
        
        return cell

    }
       
    func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    private func setupVideoCell(cell: JSQMessagesCollectionViewCell, rawMessage: Message){
        
        if cell.mediaView.subviews.count > 0{
            for view in (cell.mediaView.subviews){
                view.removeFromSuperview()
            }
        }
        
        let thumbImageView = UIImageView()
            thumbImageView.loadImageUsingCacheWithUrlString(urlString: rawMessage.thumbnailUrl!)
            thumbImageView.translatesAutoresizingMaskIntoConstraints = false
            thumbImageView.contentMode = .scaleAspectFill
        
        let playButton = PlayButton()
        
        cell.mediaView.addSubview(thumbImageView)
        
        thumbImageView.widthAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
        thumbImageView.heightAnchor.constraint(equalTo: cell.heightAnchor).isActive = true
        
        cell.mediaView.addSubview(playButton)
        
        playButton.centerXAnchor.constraint(equalTo: cell.mediaView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: cell.mediaView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.hidesWhenStopped = true
        
        
        cell.mediaView.addSubview(activityIndicatorView)
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: cell.mediaView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: cell.mediaView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let toId = user?.postKey
        let itemRef = DataService.ds.REF_MESSAGES.childByAutoId()
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let messageItem : [String: AnyObject] = ["fromId": senderId as AnyObject,
                                                 "text": text as AnyObject,
                                                 "timestamp" : timestamp as AnyObject,
                                                 "toId": toId! as AnyObject,
                                                 "mediaType": "TEXT" as AnyObject
        ]
        
        //itemRef.setValue(messageItem)
        
        itemRef.updateChildValues(messageItem) { (error, ref) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            let userMessagesRef = DataService.ds.REF_BASE.child("user_messages").child(senderId).child(toId!)
            let messageID = itemRef.key
            userMessagesRef.updateChildValues([messageID: 1])
            
            let recipientUserMessagesRef = DataService.ds.REF_BASE.child("user_messages").child(toId!).child(senderId)
            recipientUserMessagesRef.updateChildValues([messageID: 1])
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage(animated: true)
        //finishSendingMessage()
        
        isTyping = false
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert:UIAlertAction) in
            sheet.dismiss(animated: true, completion: nil)
        }
        let photoLibary = UIAlertAction(title: "Photo Library", style: .default) { (alert: UIAlertAction) in
            self.getMediaFrom(type: kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Video Library", style: .default) { (alert: UIAlertAction) in
            self.getMediaFrom(type: kUTTypeMovie)
        }
        
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
    
    //MARK: Observe Methods
    
    private func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.postKey else { return }
        let userMessagesRef = DataService.ds.REF_USERMESSAGES.child(uid).child(toId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageID = snapshot.key
            let messagesRef = DataService.ds.REF_MESSAGES.child(messageID)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.rawMessages.append(message)
                
                //let senderName = self.observeUser(message.fromId!)
                
                switch (message.mediaType!){
                case "PHOTO":
                    let url = NSURL(string: message.imageUrl!)
                    let picData = NSData(contentsOf: url! as URL)
                    let picture = UIImage(data: picData! as Data)
                    let photo = JSQPhotoMediaItem(image: picture)
                    self.messages.append(JSQMessage(senderId: message.fromId, displayName: self.senderDisplayName, media: photo))
                    photo?.appliesMediaViewMaskAsOutgoing = message.fromId == CurrentUser._postKey ? true : false
                    
                case "VIDEO":
                    let video = NSURL(string: message.imageUrl!)
                    let videoItem = JSQVideoMediaItem(fileURL: video as URL!, isReadyToPlay: true)
                    self.messages.append(JSQMessage(senderId: message.fromId, displayName: self.senderDisplayName, media: videoItem))
                    videoItem?.appliesMediaViewMaskAsOutgoing = message.fromId == CurrentUser._postKey ? true : false
                    
                case "TEXT":
                    self.messages.append(JSQMessage(senderId: message.fromId, displayName: self.senderDisplayName, text: message.text!))
                    
                default:
                    print("unknown data type")
                }
                
                self.finishReceivingMessage(animated: true)
                //self.finishReceivingMessage()
                },
                                           withCancel: nil)
            }, withCancel: nil)
        }
    /*
    private func observeUser(id: String) -> String{
        var userDisplayName: String?
        let userRef = DataService.ds.REF_USERS.child(id)
        userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                if let displayName = dictionary["UserName"] as? String{
                    userDisplayName = displayName
                    print("Inside userDisplayName is: \(userDisplayName)")
                }
            }
            }, withCancelBlock: nil)
        print("Outside userDisplayName is: \(userDisplayName)")
        return "Kevin Farm"
    }
    */
    
    //MARK: Typing Indicator Methods
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    private func observeTyping() {
        let typingIndicatorRef = DataService.ds.REF_BASE.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
        
        usersTypingQuery.observe(.value) { (data: FIRDataSnapshot!) in
            
             //3 You're the only typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            // 4 Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    //MARK: Image Zoom Methods
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingView: UIView?
    
    func performZoomInForStartingImageView(startingView: UIView, photoImage: JSQPhotoMediaItem){
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
                self.inputToolbar.alpha = 0
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
                self.inputToolbar.alpha = 1
                }, completion: { (completed) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingView?.isHidden = false
            })
        }
    }

}

extension ChatViewController: JSQMessagesCollectionViewCellDelegate{
    
    func messagesCollectionViewCellDidTapMessageBubble(_ cell: JSQMessagesCollectionViewCell!) {
        let cellIndexPath = super.collectionView.indexPath(for: cell)
        let message = messages[(cellIndexPath?.item)!]
        
        if message.isMediaMessage{
            if let mediaItem = message.media as? JSQVideoMediaItem{
                
                    pButton = cell!.mediaView.subviews[1] as? UIButton
                    pButton?.isHidden = true
                    cellAIV = cell!.mediaView.subviews[2] as? UIActivityIndicatorView
                    cellAIV?.startAnimating()
                    player = AVPlayer(url: mediaItem.fileURL)
                    playerLayer = AVPlayerLayer(player: player)
                    playerLayer!.videoGravity = AVLayerVideoGravityResize
                    playerLayer!.masksToBounds = true
                
                
                cell!.mediaView.layer.addSublayer(playerLayer!)
                playerLayer!.frame = cell!.mediaView.bounds
                player!.play()
                
                NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)

            }else if let photoImage = message.media as? JSQPhotoMediaItem{
                performZoomInForStartingImageView(startingView: cell.mediaView, photoImage: photoImage)
            }
        }
    }
    
    
    func handleVideoZoom(){
        print("Tapped to expand video")
    }
    func playerDidFinishPlaying(note: NSNotification){
        DispatchQueue.main.async {
            self.player!.pause()
            self.playerLayer!.removeFromSuperlayer()
        }
        self.pButton!.isHidden = false
        self.cellAIV!.isHidden = true
    }
    
    func messagesCollectionViewCellDidTapAvatar(_ cell: JSQMessagesCollectionViewCell!) {
        print("Did tap Avatar")
    }
    
    func messagesCollectionViewCellDidTap(_ cell: JSQMessagesCollectionViewCell!, atPosition position: CGPoint) {
        print("Did tap Collection Cell")
    }
    
    func messagesCollectionViewCell(_ cell: JSQMessagesCollectionViewCell!, didPerformAction action: Selector!, withSender sender: Any!) {
        print("Inside didPerformAction")
    }
 
}


