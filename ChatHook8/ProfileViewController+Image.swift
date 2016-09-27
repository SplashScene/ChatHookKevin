//
//  ProfileViewController+Image.swift
//  ChatHook
//
//  Created by Kevin Farm on 9/14/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            if photoChoice == "Profile"{
                uploadToFirebaseStorageUpdateProfilePic(selectedImage: selectedImage)
            }else{
                uploadToFirebaseStorageAddToGallery(selectedImage: selectedImage)
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func uploadToFirebaseStorageUpdateProfilePic(selectedImage: UIImage){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let imageName = NSUUID().uuidString
        
        let storageRef = FIRStorage.storage().reference().child("profile_images").child(uid).child("profile_pic").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(selectedImage, 0.2){
            let uploadTask = storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                    let userRef = DataService.ds.REF_USERS.child(uid).child("ProfileImage")
                    userRef.setValue(profileImageUrl)
                    
                }
            })
            uploadTask.observe(.progress) { (snapshot) in
                if let completedUnitCount = snapshot.progress?.completedUnitCount{
                    self.navigationItem.title = "\(completedUnitCount)"
                }
            }
            
            uploadTask.observe(.success) { (snapshot) in
                self.profileImageView.image = selectedImage
                self.navigationItem.title = CurrentUser._userName
                
            }
        }
        
    }
    
    private func uploadToFirebaseStorageAddToGallery(selectedImage: UIImage){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let imageName = NSUUID().uuidString
        
        let storageRef = FIRStorage.storage().reference().child("gallery_images").child(uid).child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(selectedImage, 0.2){
            let uploadTask = storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                if let galleryImageUrl = metadata?.downloadURL()?.absoluteString{
                    let galleryRef = DataService.ds.REF_GALLERYIMAGES.childByAutoId()
                    let timestamp: Int = Int(NSDate().timeIntervalSince1970)
                    let galleryItem : [String: AnyObject] = ["fromId": uid as AnyObject,
                                                             "timestamp" : timestamp as AnyObject,
                                                             "galleryImageUrl": galleryImageUrl as AnyObject
                    ]
                    
                    galleryRef.updateChildValues(galleryItem, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print(error?.localizedDescription)
                            return
                        }
                        
                        let galleryUserRef = DataService.ds.REF_USERS_GALLERY.child(uid)
                        let galleryID = galleryRef.key
                        galleryUserRef.updateChildValues([galleryID: 1])
                        
                    })
                    
                }
            })
            
            uploadTask.observe(.progress) { (snapshot) in
                if let completedUnitCount = snapshot.progress?.completedUnitCount{
                    self.navigationItem.title = "\(completedUnitCount)"
                }
            }
            
            uploadTask.observe(.success) { (snapshot) in
                self.navigationItem.title = CurrentUser._userName
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("I hit cancel")
    }
    
    func takePhotoWithCamera(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            showPhotoMenu()
        }else{
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {
            _ in
            self.takePhotoWithCamera()
        })
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: {
            _ in
            self.choosePhotoFromLibrary()
        })
        alertController.addAction(chooseFromLibraryAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
