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
//import FBSDKLoginKit
//import FBSDKCoreKit
import Firebase


class IntroViewController: UIViewController {
    @IBOutlet weak var videoView: UIView!
    
    let chatHookLogo: UILabel = {
        let logoLabel = UILabel()
            logoLabel.translatesAutoresizingMaskIntoConstraints = false
            logoLabel.alpha = 0.0
            logoLabel.text = "ChatHook"
            logoLabel.font = UIFont(name: "Avenir Medium", size:  60.0)
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
            //facebookView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fbButtonPressed)))
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
            fbLabel.font = UIFont(name: "Avenir Medium", size:  24.0)
            fbLabel.backgroundColor = UIColor.clear
            fbLabel.textColor = UIColor.blue
            fbLabel.sizeToFit()
            fbLabel.textAlignment = NSTextAlignment.center
        return fbLabel
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

    
    let loginLabel: UILabel = {
        let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.alpha = 1.0
            label.text = "Email Login/Signup"
            label.font = UIFont(name: "Avenir Medium", size:  18.0)
            label.backgroundColor = UIColor.clear
            label.textColor = UIColor.blue
            label.sizeToFit()
            label.textAlignment = NSTextAlignment.center
        return label

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
    
    let passwordTextField: MaterialTextField = {
        let ptf = MaterialTextField()
            ptf.placeholder = "Password"
            //ptf.secureTextEntry = true
            ptf.autocapitalizationType = .none
            ptf.translatesAutoresizingMaskIntoConstraints = false
        return ptf
    }()
    
    lazy var registerButton: MaterialButton = {
        let button = MaterialButton(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Sign In", for: .normal)
            button.addTarget(self, action: #selector(attemptLogin), for: UIControlEvents.touchUpInside)
        return button
    }()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        //NSUserDefaults.standardUserDefaults().setValue("q3KcxAnXh9SXAe9UshCKvPteXgq1", forKey: KEY_UID)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil{
//            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
//        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    
    func setupView(){
        let path = NSURL(fileURLWithPath: Bundle.main.path(forResource: "introVideo", ofType: "mov")!)
        let player = AVPlayer(url: path as URL)
        
        let newLayer = AVPlayerLayer(player: player)
        
        newLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        newLayer.masksToBounds = true
        self.videoView.layer.addSublayer(newLayer)
        newLayer.frame = view.bounds
        
        player.play()
        
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        
        NotificationCenter.default.addObserver(self, selector:#selector(IntroViewController.videoDidPlayToEnd), name: NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"), object: player.currentItem)
        
        self.videoView.addSubview(chatHookLogo)
        self.videoView.addSubview(facebookContainerView)
        self.videoView.addSubview(loginContainerView)
        
        setupChatHookLogoView()
        setupFacebookContainerView()
        setupLoginContainerView()
        
        //self.createViews(self.videoView)
        
    }//end func setupView
    
    func videoDidPlayToEnd(notification: NSNotification){
        let player: AVPlayerItem = notification.object as! AVPlayerItem
            player.seek(to: kCMTimeZero)
    }//end func videoDidPlayToEnd
    
    func setupChatHookLogoView(){
        //need x, y, width and height constraints
        chatHookLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        chatHookLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        UIView.animate(withDuration: 0.5,
                                   delay: 1.5,
                                   options: [],
                                   animations: { self.chatHookLogo.alpha = 1.0 },
                                   completion: nil)
    }
    
    func setupFacebookContainerView(){
        //need x, y, width and height constraints
        facebookContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        facebookContainerView.topAnchor.constraint(equalTo: chatHookLogo.bottomAnchor, constant: 8).isActive = true
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
    
    func setupLoginContainerView(){
        //need x, y, width and height constraints
        loginContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginContainerView.topAnchor.constraint(equalTo: facebookContainerView.bottomAnchor, constant: 15).isActive = true
        loginContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        loginContainerView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        loginContainerView.addSubview(inputsContainerView)
        loginContainerView.addSubview(loginLabel)
        loginContainerView.addSubview(registerButton)
        
        inputsContainerView.centerXAnchor.constraint(equalTo: loginContainerView.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: loginContainerView.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: loginContainerView.widthAnchor, constant: -24).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        //need x, y, width, height constraints for login label - size to fit
        loginLabel.leftAnchor.constraint(equalTo: loginContainerView.leftAnchor, constant: 8).isActive = true
        loginLabel.topAnchor.constraint(equalTo: loginContainerView.topAnchor, constant: 8).isActive = true
        
        //need x, y, width, height constraints for email text field
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
        //need x, y, width, height constraints for email separator view
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints for password text field
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
        //need x, y, width, height constraints for login label - size to fit
        registerButton.rightAnchor.constraint(equalTo: loginContainerView.rightAnchor, constant: -8).isActive = true
        registerButton.bottomAnchor.constraint(equalTo: loginContainerView.bottomAnchor, constant: -8).isActive = true
        registerButton.widthAnchor.constraint(equalToConstant: 125).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 35).isActive = true


        
        UIView.animate(withDuration: 0.5,
                                   delay: 1.5,
                                   options: [],
                                   animations: { self.facebookContainerView.alpha = 0.75;
                                                 self.loginContainerView.alpha = 0.75},
                                   completion: nil)
    }
    /*
    func fbButtonPressed(){
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email","public_profile"], fromViewController: nil) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error: \(facebookError)")
            }else{
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with facebook. \(accessToken)")
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        print("Login Failed. \(error)")
                    }else{
                        print("Logged In! \(user)")
                        
                        let userData = ["provider": credential.provider,
                                        "UserName": "AnonymousPoster",
                                        "ProfileImage":"http://imageshack.com/a/img922/8259/MrQ96I.png"]
                        DataService.ds.createFirebaseUser(user!.uid, user: userData )
                        
                        NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                        //self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }//end else
                })//end withCompletionBlock
            }//end else
        }//end facebook login handler
    }
    */
    func attemptLogin(){
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            showErrorAlert(title: "Email and Password Required", msg: "You must enter an email and password to login")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {(user, error) in
            
            if error != nil{
                print(error)
                
                if error!._code == STATUS_NO_INTERNET{
                    self.showErrorAlert(title: "No Internet Connection", msg: "You currently have no internet connection. Please try again later.")
                }
                
                if error!._code == STATUS_ACCOUNT_NONEXIST{
                    
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        
                        if error != nil{
                            error!._code == STATUS_ACCOUNT_WEAKPASSWORD ?
                                self.showErrorAlert(title: "Weak Password", msg: "The password must be more than 5 characters.") :
                                self.showErrorAlert(title: "Could not create account",
                                    msg: "Problem creating account. Try something else")
                        }else{
                            UserDefaults.standard.setValue(user!.uid, forKey: KEY_UID)
                            
                            let userData = ["provider": "email",
                                            "UserName": "AnonymousPoster",
                                            "email": email,
                                            "ProfileImage":"http://imageshack.com/a/img922/8259/MrQ96I.png"]
                            
                            DataService.ds.createFirebaseUser(uid: user!.uid, user: userData as Dictionary<String, AnyObject>)
                            
                            self.handleRegisterSegue()
                        }
                    })
                } else if error!._code == STATUS_ACCOUNT_WRONGPASSWORD{
                    self.showErrorAlert(title: "Incorrect Password", msg: "The password that you entered does not match the one we have for your email address")
                }
            } else {
                //set only to allow different signins
                UserDefaults.standard.setValue(user!.uid, forKey: KEY_UID)
                self.handleReturningUser()
                
            }
        })
    }
    
    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func handleRegisterSegue(){
        let loginController = FinishRegisterController()
        loginController.introViewController = self
        present(loginController, animated: true, completion: nil)
    }
    
    func handleReturningUser(){
        let tabController = MainTabBar()
        tabController.introViewController = self
        present(tabController, animated: true, completion: nil)
    }
    
}//end class


