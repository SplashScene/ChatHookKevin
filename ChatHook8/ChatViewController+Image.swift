//
//  ChatViewController+Image.swift
//  ChatHook
//
//  Created by Kevin Farm on 9/4/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import AVFoundation

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            uploadToFirebaseStorageUsingSelectedMedia(image: selectedImage, video: nil, completion: { (imageUrl) in
                
                self.enterIntoMessagesAndUserMessagesDatabaseWithImageUrl(metadata: "image/jpg", thumbnailURL: nil, fileURL:imageUrl)
            })
            //uploadToFirebaseStorageUsingSelectedMedia(selectedImage, video: nil)
        }
        
        if let video = info["UIImagePickerControllerMediaURL"] as? NSURL{
            print("INSIDE VIDEO MEDIA COMPLETION")
            uploadToFirebaseStorageUsingSelectedMedia(image: nil, video: video, completion: { (imageUrl) in
                
                self.enterIntoMessagesAndUserMessagesDatabaseWithImageUrl(metadata: "video/mp4",thumbnailURL: nil, fileURL:imageUrl)
            })
            //uploadToFirebaseStorageUsingSelectedMedia(nil, video: video)
        }
        
        self.finishSendingMessage()
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingSelectedMedia(image: UIImage?, video: NSURL?, completion: @escaping (_ imageUrl: String) -> ()){
        let imageName = NSUUID().uuidString
        
        if let picture = image{
            let ref = FIRStorage.storage().reference().child("message_images").child(senderId).child("photos").child(imageName)
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
                }
            }
            
        } else if let movie = video {
            print("INSIDE MOVIE SECTION OF THE UPLOAD")
            let ref = FIRStorage.storage().reference().child("message_images").child(senderId).child("videos").child(imageName)
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
                                self.enterIntoMessagesAndUserMessagesDatabaseWithImageUrl(metadata: metadata!.contentType!, thumbnailURL: imageUrl, fileURL: videoUrl)
        
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
                }
            }
        }
    }
    
    private func enterIntoMessagesAndUserMessagesDatabaseWithImageUrl(metadata: String, thumbnailURL: String?, fileURL: String){
        let toId = user?.postKey
        let itemRef = DataService.ds.REF_MESSAGES.childByAutoId()
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let messageItem: Dictionary<String,AnyObject>
        
        if metadata == "video/mp4"{
            print("I am HERE!!!!")
            messageItem = ["fromId": senderId as AnyObject,
                           "imageUrl": fileURL as AnyObject,
                           "timestamp" : timestamp as AnyObject,
                           "toId": toId! as AnyObject,
                           "mediaType": "VIDEO" as AnyObject,
                           "thumbnailUrl": thumbnailURL! as AnyObject
            ]
        }else{
            messageItem = ["fromId": senderId as AnyObject,
                           "imageUrl": fileURL as AnyObject,
                           "timestamp" : timestamp as AnyObject,
                           "toId": toId! as AnyObject,
                           "mediaType": "PHOTO" as AnyObject
            ]
        }
        
        
        itemRef.updateChildValues(messageItem) { (error, ref) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            let userMessagesRef = DataService.ds.REF_BASE.child("user_messages").child(self.senderId).child(toId!)
            let messageID = itemRef.key
            userMessagesRef.updateChildValues([messageID: 1])
            
            let recipientUserMessagesRef = DataService.ds.REF_BASE.child("user_messages").child(toId!).child(self.senderId)
            recipientUserMessagesRef.updateChildValues([messageID: 1])
        }
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
