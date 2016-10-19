//
//  ViewController.swift
//  ChatHook
//
//  Created by Kevin Farm on 5/10/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import FBSDKLoginKit
import Firebase
import FirebaseStorage


class IntroViewController: UIViewController {
    @IBOutlet weak var videoView: UIView!
    var textFieldMultiplier: CGFloat = 1/3
    var userNameTextFieldMultiplier:CGFloat = 1/3
    var loginContainerViewHeightAnchor: NSLayoutConstraint?
    var loginContainerViewCenterAnchor: NSLayoutConstraint?
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var emailTextFieldViewHeightAnchor: NSLayoutConstraint?
    var userNameTextFieldViewHeightAnchor: NSLayoutConstraint?
    var passwordSeparatorViewHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldViewHeightAnchor: NSLayoutConstraint?
    var chatHookLogoViewBottomAnchor: NSLayoutConstraint?
    var userEmail: String?
    var userProvider: String?
    var profileImageChanged: Bool = false
    var alreadyRegistered: Bool = false
    var viewsArray:[UIView]? = []
    var timer: Timer?
    
    let chatHookLogo: UILabel = {
        let logoLabel = UILabel()
            logoLabel.translatesAutoresizingMaskIntoConstraints = false
            logoLabel.alpha = 0.0
            logoLabel.text = "ChatHook"
            logoLabel.font = UIFont(name: FONT_AVENIR_MEDIUM, size:  60.0)
            logoLabel.backgroundColor = UIColor.clear
            logoLabel.textColor = UIColor.white
            logoLabel.sizeToFit()
            logoLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
            logoLabel.layer.shadowOpacity = 0.7
            logoLabel.layer.shadowRadius = 2
            logoLabel.textAlignment = NSTextAlignment.center
        return logoLabel
    }()
    
    lazy var facebookContainerView: UIView = {
        let facebookView = UIView()
            facebookView.translatesAutoresizingMaskIntoConstraints = false
            facebookView.alpha = 0.0
            facebookView.backgroundColor = UIColor.white
            facebookView.layer.cornerRadius = 5.0
            facebookView.layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).cgColor
            facebookView.layer.shadowOpacity = 0.8
            facebookView.layer.shadowRadius = 5.0
            facebookView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            facebookView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fbButtonPressed)))
        return facebookView
    }()
    
    let facebookLogoView: UIImageView = {
        let fbLogo  = UIImageView()
            fbLogo.translatesAutoresizingMaskIntoConstraints = false
            fbLogo.image = UIImage(named:"fb-icon")
        return fbLogo
    }()
    
    let facebookLabel: UILabel = {
        let fbLabel = UILabel()
            fbLabel.translatesAutoresizingMaskIntoConstraints = false
            fbLabel.text = "Login With Facebook"
            fbLabel.font = UIFont(name: FONT_AVENIR_MEDIUM, size:  24.0)
            fbLabel.backgroundColor = UIColor.clear
            fbLabel.textColor = UIColor.blue
            fbLabel.sizeToFit()
            fbLabel.textAlignment = NSTextAlignment.center
        return fbLabel
    }()
    
    lazy var eMailContainerView: UIView = {
        let eMailView = UIView()
            eMailView.translatesAutoresizingMaskIntoConstraints = false
            eMailView.alpha = 0.0
            eMailView.backgroundColor = UIColor.white
            eMailView.layer.cornerRadius = 5.0
            eMailView.layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).cgColor
            eMailView.layer.shadowOpacity = 0.8
            eMailView.layer.shadowRadius = 5.0
            eMailView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            eMailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(eMailButtonPressed)))
        return eMailView
    }()
    
    let eMailLogoView: UIImageView = {
        let eMailLogo  = UIImageView()
            eMailLogo.translatesAutoresizingMaskIntoConstraints = false
            eMailLogo.image = UIImage(named:"letter")
            eMailLogo.contentMode = .scaleAspectFit
        return eMailLogo
    }()
    
    let eMailLabel: UILabel = {
        let emLabel = UILabel()
            emLabel.translatesAutoresizingMaskIntoConstraints = false
            emLabel.text = "Login With Email"
            emLabel.font = UIFont(name: FONT_AVENIR_MEDIUM, size:  24.0)
            emLabel.backgroundColor = UIColor.clear
            emLabel.textColor = UIColor.blue
            emLabel.sizeToFit()
            emLabel.textAlignment = NSTextAlignment.center
        return emLabel
    }()
    
    lazy var profileImageView: MaterialImageView = {
        let imageView = MaterialImageView(frame: CGRect(x: 0, y: 0, width: 125, height: 125))
            imageView.image = UIImage(named: "genericProfile")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.alpha = 0.0
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickPhoto)))
            imageView.isUserInteractionEnabled = true
        return imageView
    }()

    let loginContainerView: UIView = {
        let loginView = UIView()
            loginView.translatesAutoresizingMaskIntoConstraints = false
            loginView.alpha = 0.0
            loginView.backgroundColor = UIColor.white
            loginView.layer.cornerRadius = 5.0
            loginView.layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).cgColor
            loginView.layer.shadowOpacity = 0.8
            loginView.layer.shadowRadius = 5.0
            loginView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        return loginView
    }()
    
    let inputsContainerView: UIView = {
        let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 5
            view.layer.masksToBounds = true
        return view
    }()

    let emailTextField: MaterialTextField = {
        let etf = MaterialTextField()
            etf.placeholder = "Email"
            etf.translatesAutoresizingMaskIntoConstraints = false
            etf.autocapitalizationType = .none
        return etf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
            view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
            view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordSeparatorView: UIView = {
        let view = UIView()
            view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
            view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: MaterialTextField = {
        let ptf = MaterialTextField()
            ptf.placeholder = "Password"
            ptf.isSecureTextEntry = true
            ptf.autocapitalizationType = .none
            ptf.translatesAutoresizingMaskIntoConstraints = false
        return ptf
    }()
    
    let userNameTextField: MaterialTextField = {
        let ntf = MaterialTextField()
            ntf.placeholder = "User Name"
            ntf.translatesAutoresizingMaskIntoConstraints = false
        return ntf
    }()
    
    lazy var registerButton: MaterialButton = {
        let button = MaterialButton(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Sign In", for: .normal)
            button.isHidden = true
            button.addTarget(self, action: #selector(handleNewOrReturningUserForLogin), for: UIControlEvents.touchUpInside)
        return button
    }()

    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        viewsArray = [chatHookLogo, facebookContainerView, eMailContainerView, loginContainerView, profileImageView, registerButton]
        setupKeyboardObservers()
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.value(forKey: USER_EMAIL) != nil {
            chatHookLogoViewBottomAnchor?.constant = -16
            facebookContainerView.isHidden = false
            eMailContainerView.isHidden = true
            loginContainerView.isHidden = false
            passwordTextField.text = ""
//            textFieldMultiplier = 1/2
//            userNameTextFieldMultiplier = 0
//            loginContainerViewHeightAnchor?.constant = 124
//            loginContainerViewCenterAnchor?.constant = 30
//            inputsContainerViewHeightAnchor?.constant = 100
            inputsContainerView.isHidden = false
            registerButton.setTitle("Sign In", for: .normal)
            //setupLoginContainerViewNewUser()
        }else {
            self.setupView()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.value(forKey: KEY_UID) != nil{
            timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.self.handleReturningUser), userInfo: nil, repeats: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //MARK: - Setup Methods
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(IntroViewController.handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IntroViewController.handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setupView(){
        let path = NSURL(fileURLWithPath: Bundle.main.path(forResource: "introVideo", ofType: "mov")!)
        let player = AVPlayer(url: path as URL)
        
        let newLayer = AVPlayerLayer(player: player)
            newLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            newLayer.masksToBounds = true
            newLayer.frame = view.bounds
        self.videoView.layer.addSublayer(newLayer)
        
        player.play()
        
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        
        NotificationCenter.default.addObserver(self, selector:#selector(IntroViewController.videoDidPlayToEnd), name: NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"), object: player.currentItem)
        
        for view in viewsArray!{
            self.videoView.addSubview(view)
        }
        
        setupChatHookLogoView()
        setupFacebookContainerView()
        setupEmailContainerView()
        setupLoginContainerViewNewUser()
        setupProfileImageView()
    }//end func setupView
    
    func hideViews(){
        self.registerButton.isHidden = true
    }
    
    func setupChatHookLogoView(){
        //need x, y, width and height constraints
        chatHookLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        chatHookLogoViewBottomAnchor = chatHookLogo.bottomAnchor.constraint(equalTo: facebookContainerView.topAnchor, constant: -16)
        chatHookLogoViewBottomAnchor?.isActive = true
        UIView.animate(withDuration: 0.5,
                                   delay: 1.5,
                                   options: [],
                                   animations: { self.chatHookLogo.alpha = 1.0 },
                                   completion: nil)
        UIView.animate(withDuration: 0.5,
                       delay: 1.5,
                       options: [],
                       animations: { self.facebookContainerView.alpha = 1.0;
                                     self.eMailContainerView.alpha = 1.0},
                       completion: nil)
    }
    
    func setupFacebookContainerView(){
        //need x, y, width and height constraints
        facebookContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        facebookContainerView.topAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        facebookContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        facebookContainerView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        facebookContainerView.addSubview(facebookLogoView)
        facebookContainerView.addSubview(facebookLabel)
        
        facebookLogoView.leftAnchor.constraint(equalTo: facebookContainerView.leftAnchor, constant: 8).isActive = true
        facebookLogoView.centerYAnchor.constraint(equalTo: facebookContainerView.centerYAnchor).isActive = true
        facebookLogoView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        facebookLogoView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        facebookLabel.centerXAnchor.constraint(equalTo: facebookContainerView.centerXAnchor).isActive = true
        facebookLabel.centerYAnchor.constraint(equalTo: facebookContainerView.centerYAnchor).isActive = true
        facebookLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        facebookLabel.heightAnchor.constraint(equalTo: facebookContainerView.heightAnchor).isActive = true
    }
    
    func setupEmailContainerView(){
        //need x, y, width and height constraints
        eMailContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //eMailContainerView.topAnchor.constraint(equalTo: facebookLoginButton.bottomAnchor, constant: 8).isActive = true
        eMailContainerView.topAnchor.constraint(equalTo: facebookContainerView.bottomAnchor, constant: 8).isActive = true
        eMailContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        eMailContainerView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        eMailContainerView.addSubview(eMailLogoView)
        eMailContainerView.addSubview(eMailLabel)
        
        eMailLogoView.leftAnchor.constraint(equalTo: eMailContainerView.leftAnchor, constant: 8).isActive = true
        eMailLogoView.centerYAnchor.constraint(equalTo: eMailContainerView.centerYAnchor).isActive = true
        eMailLogoView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        eMailLogoView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        eMailLabel.centerXAnchor.constraint(equalTo: eMailContainerView.centerXAnchor).isActive = true
        eMailLabel.centerYAnchor.constraint(equalTo: eMailContainerView.centerYAnchor).isActive = true
        eMailLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        eMailLabel.heightAnchor.constraint(equalTo: eMailContainerView.heightAnchor).isActive = true
    }

    func setupLoginContainerViewNewUser(){
        //need x, y, width and height constraints
        loginContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginContainerViewCenterAnchor = loginContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        loginContainerViewCenterAnchor?.isActive = true
        loginContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        loginContainerViewHeightAnchor = loginContainerView.heightAnchor.constraint(equalToConstant: 174)
        loginContainerViewHeightAnchor?.isActive = true
        
        loginContainerView.addSubview(inputsContainerView)

        inputsContainerView.centerXAnchor.constraint(equalTo: loginContainerView.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: loginContainerView.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: loginContainerView.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(userNameTextField)
        inputsContainerView.addSubview(passwordSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldViewHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: textFieldMultiplier)
        emailTextFieldViewHeightAnchor?.isActive = true
        
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        userNameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        userNameTextField.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor).isActive = true
        userNameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        userNameTextFieldViewHeightAnchor = userNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: userNameTextFieldMultiplier)
        userNameTextFieldViewHeightAnchor?.isActive = true
        
        passwordSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordSeparatorView.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor).isActive = true
        passwordSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordSeparatorViewHeightAnchor = passwordSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        passwordSeparatorViewHeightAnchor?.isActive = true
        
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: passwordSeparatorView.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldViewHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: textFieldMultiplier)
        passwordTextFieldViewHeightAnchor?.isActive = true

        setupRegisterButton()
    }
    
    func setupRegisterButton(){
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        registerButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    func setupSeparatorView(){
        
    }
    
    func setupProfileImageView(){
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginContainerView.topAnchor, constant: -8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 125).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 125).isActive = true
    }
    
    //MARK: - Login Methods
    func fbButtonPressed(){
        let facebookLogin = FBSDKLoginManager()
            facebookLogin.logIn(withReadPermissions: ["email", "public_profile"], from: nil) { (FBSDKLoginManagerLoginResult, facebookError) in
                if facebookError != nil {
                    print("Facebook login failed. Error: \(facebookError)")
                }else{
                    //let accessToken = FBSDKAccessToken.current().tokenString
                    FBSDKProfile.enableUpdates(onAccessTokenChange: true)
                    
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                            if error != nil {
                                print("Login Failed. \(error)")
                            }else{
                                let parameters = ["fields": "email, first_name, last_name, name, picture.type(large)"]
                                FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { (connection, result, error) in
                                    if error != nil{
                                        print(error?.localizedDescription)
                                        return
                                    }
                                    let result1 = result as? NSDictionary
                                    if let picture = result1?["picture"] as? NSDictionary,
                                       let data = picture["data"] as? NSDictionary,
                                       let url = data["url"] as? String,
                                       let name = result1?["name"] as? String,
                                       let email = result1?["email"] as? String{
                                            
                                            let userData = ["provider": credential.provider,
                                                            "Email": email,
                                                            "UserName": name,
                                                            "ProfileImage": url]
                                            
                                            DataService.ds.createFirebaseUser(uid: user!.uid, user: userData as Dictionary<String, AnyObject> )
                                            
                                            UserDefaults.standard.setValue(user!.uid, forKey: KEY_UID)
                                            self.handleReturningUser()
                                    }
                                })
                            }//end else
                        })//end withCompletionBlock
                }//end else
        }//end facebook login handler
    }
    
    func handleNewOrReturningUserForLogin(){
        print("Inside Handle New or Returning")
        if UserDefaults.standard.value(forKey: USER_EMAIL) != nil{
            attemptLoginAlreadyUser()
        }else{
            attemptLoginNewUser()
        }
    }
    
    func attemptLoginNewUser(){
        print("Inside Login New User")
        if !profileImageChanged { showErrorAlert(title: "Profile Image Required", msg: "You must provide a profile picture.")
            return }
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let userName = userNameTextField.text else { showErrorAlert(title: "Email and Password Required", msg: "You must enter an email and password to login")
            return
        }
        //let isNameAlreadyRegistered = checkAlreadyUserName(userName: userName)
        
        self.createAndSignInUser(email: email, password: password, username: userName)
        
        
    }//end method
    
    func checkAlreadyUserName(userName: String) -> Bool {
        var alreadyRegisteredUserName: Bool?
        let userLetterNameRef = DataService.ds.REF_USERS_NAMES.child(String(userName.uppercased()[userName.startIndex])).child(userName.lowercased())
            print("The user name ref is: \(userLetterNameRef)")
            userLetterNameRef.observe(.value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull{
                    alreadyRegisteredUserName = false
                }else{
                    alreadyRegisteredUserName = true
                }
                }, withCancel: nil)
            return alreadyRegisteredUserName!
    }

    func createAndSignInUser(email: String, password: String, username: String){
        print("Inside Create and Sign In User")
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {(user, error) in
            print("Inside User Signed In with Email")
            self.userEmail = email
            self.userProvider = "email"
            
            if error != nil{
                print(error)
                if error!._code == STATUS_NO_INTERNET{
                    self.showErrorAlert(title: "No Internet Connection", msg: "You currently have no internet connection. Please try again later.")
                }
                
                if error!._code == STATUS_ACCOUNT_NONEXIST{
                    self.registerButton.setTitle("Registering...", for: .normal)
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        
                        if error != nil{
                            error!._code == STATUS_ACCOUNT_WEAKPASSWORD ?
                                self.showErrorAlert(title: "Weak Password", msg: "The password must be more than 5 characters.") :
                                self.showErrorAlert(title: "Could not create account", msg: "Problem creating account. Try something else")
                        }else{
                            UserDefaults.standard.setValue(user!.uid, forKey: KEY_UID)
                            UserDefaults.standard.setValue(self.userEmail, forKey: USER_EMAIL)
                            self.uploadPictureAndSetupCurrentUser(userName: username)
                        }
                    })
                } else if error!._code == STATUS_ACCOUNT_WRONGPASSWORD{
                    self.showErrorAlert(title: "Incorrect Password", msg: "The password that you entered does not match the one we have for your email address")
                    return
                } else if error!._code == STATUS_ACCOUNT_BADEMAIL{
                    self.showErrorAlert(title: "Email Format", msg: "Your email address is not formatted correctly. Please try again")
                    return
                }

            } else {
                //set only to allow different signins
                UserDefaults.standard.setValue(user!.uid, forKey: KEY_UID)
                self.handleReturningUser()
            }
        })
    }
    
    func attemptLoginAlreadyUser(){
        print("Inside Already User")
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
                showErrorAlert(title: "Email and Password Required", msg: "You must enter an email and password to login")
                return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                print(error)
                if error!._code == STATUS_NO_INTERNET{
                    self.showErrorAlert(title: "No Internet Connection", msg: "You currently have no internet connection. Please try again later.")
                }
                if error!._code == STATUS_ACCOUNT_WRONGPASSWORD{
                    self.showErrorAlert(title: "Incorrect Password", msg: "The password that you entered does not match the one we have for your email address")
                    return
                }
            }else{
                UserDefaults.standard.setValue(user!.uid, forKey: KEY_UID)
                self.handleReturningUser()
            }
        })
    }//end method
    
    //MARK: - Handler Methods
    func handleReturningUser(){
        let tabController = MainTabBar()
            tabController.introViewController = self
        present(tabController, animated: true, completion: nil)
    }
    
    func uploadPictureAndSetupCurrentUser(userName: String){
        guard   let userName = userNameTextField.text, userName != "",
                let uEmail = self.userEmail,
                let uProvider = self.userProvider,
                let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child(uid).child("\(imageName).jpg")
            
            if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.2){
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpg"
                storageRef.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                        let values =
                            ["provider": uProvider,
                             "Email": uEmail,
                             "UserName": userName,
                             "ProfileImage": profileImageUrl]
                        
                        self.postRegisteredUserToFirebase(values: values)
                    }
                })
            }
    }
    
    func postRegisteredUserToFirebase(values:[String: String]){
        for (key, value) in values{
            DataService.ds.REF_USER_CURRENT.child(key).setValue(value)
        }
        
        if let userName = values["UserName"]{
            let firstLetter = String(userName.uppercased()[userName.startIndex])
            let userNameRef = DataService.ds.REF_USERS_NAMES.child(firstLetter)
            userNameRef.updateChildValues([userName.lowercased(): 1])
        }
        
        self.profileImageView.isHidden = true
        self.loginContainerView.isHidden = true
        self.facebookContainerView.isHidden = false
        self.eMailContainerView.isHidden = false
        
        setupChatHookLogoView()
        setupFacebookContainerView()
        setupEmailContainerView()
        handleReturningUser()
    }

    func handleKeyboardWillShow(notification: Notification){
            //        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
//        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
//        let keyboardRectangle = keyboardFrame.cgRectValue
//        let keyboardHeight = keyboardRectangle.height
//        let keyboardDuration = userInfo.value(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
//        
//        loginContainerViewBottomAnchor?.constant = -keyboardHeight
//        UIView.animate(withDuration: keyboardDuration){
//            self.view.layoutIfNeeded()
//        }
//       
//        print("The height of the keyboard is: \(keyboardHeight)")
    }
    
    func handleKeyboardWillHide(notification: Notification){
        //loginContainerViewBottomAnchor?.constant = 0
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardDuration = userInfo.value(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
        
        UIView.animate(withDuration: keyboardDuration){
            self.view.layoutIfNeeded()
        }
    }
    
    func eMailButtonPressed(){
        print("Email button pressed")
        chatHookLogoViewBottomAnchor?.constant = -200
        facebookContainerView.isHidden = true
        eMailContainerView.isHidden = true
            UIView.animate(withDuration: 0.5){
                self.view.layoutIfNeeded()
            }
        
            UIView.animate(withDuration: 0.5,
                           delay: 1.0,
                           options: [],
                           animations: { self.loginContainerView.alpha = 1.0;
                                         self.profileImageView.alpha = 1.0;
                                         self.registerButton.isHidden = false
                                       },
                           completion: nil)
    }
    
    //MARK: - Error Alert
    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    //MARK: - Video Played To End
    func videoDidPlayToEnd(notification: NSNotification){
        let player: AVPlayerItem = notification.object as! AVPlayerItem
            player.seek(to: kCMTimeZero)
    }//end func videoDidPlayToEnd
}//end class

extension IntroViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


