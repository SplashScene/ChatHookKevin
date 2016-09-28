//
//  FinishRegisterController.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/21/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


class FinishRegisterController: UIViewController {

    var dbRef: FIRDatabaseReference!
    var introViewController: IntroViewController?
    let currentUser = DataService.ds.REF_USER_CURRENT
    
    let inputsContainerView: UIView = {
        let view = UIView()
            view.backgroundColor = UIColor.white
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 5
            view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
            button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
            button.setTitle("Register", for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = 5
            button.layer.masksToBounds = true
            button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let userNameTextField: MaterialTextField = {
        let ntf = MaterialTextField()
            ntf.placeholder = "User Name"
            ntf.translatesAutoresizingMaskIntoConstraints = false
        return ntf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
            view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
            view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let fullNameTextField: MaterialTextField = {
        let etf = MaterialTextField()
            etf.placeholder = "Full Name"
            etf.translatesAutoresizingMaskIntoConstraints = false
        return etf
    }()
    
    lazy var profileImageView: MaterialImageView = {
        let imageView = MaterialImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            imageView.image = UIImage(named: "genericProfile")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickPhoto)))
            imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let progressView: UIProgressView = { // the progress bar
        let progView = UIProgressView()
            progView.translatesAutoresizingMaskIntoConstraints = false
            progView.isHidden = true
        return progView
    }()
    
    let activityIndicator: UIActivityIndicatorView = { //the spinning gear
        let actInd = UIActivityIndicatorView()
            actInd.translatesAutoresizingMaskIntoConstraints = false
            actInd.isHidden = true
        return actInd
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(progressView)
        view.addSubview(activityIndicator)
        
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupActivity()
        
    }
    
    func setupProfileImageView(){
        //need x, y, width, height constraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupInputsContainerView(){
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        inputsContainerView.addSubview(userNameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(fullNameTextField)
        
        
        //need x, y, width, height constraints for name text field
        userNameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        userNameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        userNameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        userNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
        //need x, y, width, height constraints for name separator view
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints for email text field
        fullNameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        fullNameTextField.topAnchor.constraint(equalTo: nameSeparatorView.bottomAnchor).isActive = true
        fullNameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        fullNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2).isActive = true
    }
    
    func setupLoginRegisterButton(){
        //need x, y, width, height constraints
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupActivity(){
        //need x, y, width, height constraints
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 16).isActive = true
        progressView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16).isActive = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: 16).isActive = true
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func registerButtonTapped() {
        
        guard let userName = userNameTextField.text, userName != "",
            let fullName = fullNameTextField.text, fullName != ""
             else { return }
        
        
        progressView.progress = 0.0
        progressView.isHidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        
        let imageName = NSUUID().uuidString
        
        let storageRef = FIRStorage.storage().reference().child("profile_images").child(userName).child("\(imageName).jpg")
        
        if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.2){
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                    let values =
                        ["UserName": userName,
                         "ProfileImage": profileImageUrl,
                         "FullName": fullName]
                    
                        self.postRegisteredUserToFirebase(values: values, progress: {[unowned self] percent in
                            self.progressView.setProgress(percent, animated: true)
                        })
                }
            })
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func postRegisteredUserToFirebase(values:[String: String], progress: (_ percent: Float) -> Void){
        currentUser.child("UserName").setValue(values["UserName"])
        currentUser.child("FullName").setValue(values["FullName"])
        currentUser.child("ProfileImage").setValue(values["ProfileImage"])
        self.progressView.isHidden = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        handleRegisterSegue()
    }
    
    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    
    func handleRegisterSegue(){
        let tabController = MainTabBar()
            tabController.registerViewController = self
        present(tabController, animated: true, completion: nil)
    }
    
}//end view controller


