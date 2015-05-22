//
//  ViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/4/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController, FBLoginViewDelegate , GPPSignInDelegate{


    @IBOutlet weak var fbLoginView: FBLoginView!
    @IBOutlet var twtButton: UIButton!
    
    var kClientId = "517644806961-ocmqel4aloa86mtsn5jsmmuvi3fcdpln.apps.googleusercontent.com";

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var signIn = GPPSignIn.sharedInstance();
        signIn.shouldFetchGooglePlusUser = true;
        signIn.clientID = kClientId;
        signIn.scopes = [kGTLAuthScopePlusLogin,kGTLAuthScopePlusUserinfoEmail];
        signIn.trySilentAuthentication();
        signIn.delegate = self;

        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Google + login
    @IBAction func signInWithGoogle(sender: AnyObject) {
        var signIn = GPPSignIn.sharedInstance();
        signIn.authenticate();
    }
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
       if (GPPSignIn.sharedInstance().googlePlusUser != nil){
            println("Sign in")
            var user = GPPSignIn.sharedInstance().googlePlusUser
            var userId = GPPSignIn.sharedInstance().googlePlusUser.identifier
            
            var userEmail = user.emails.first?.value ?? ""
            println(user.name.JSONString());
        
            var userImage = String(stringInterpolationSegment: user.image.url)+"&sz=100"
        
        println(userImage)
            let params:[String: String] = [
                "google_key" : userId,
                "names" : user.name.givenName,
                "surnames":user.name.familyName,
                "birth_date" : "2015-01-01",
                "email": userEmail!,
                "main_image":userImage]
            
            self.socialLogin("google", params: params)

            
        } else {
           println("Signed out.");
        }
    
    }
    
    //Twitter login
    @IBAction func signInWithTwitter(sender: UIButton) {
        Twitter.sharedInstance().logInWithCompletion { (session: TWTRSession!, error: NSError!) -> Void in
            if (session != nil) {
                Twitter.sharedInstance().logInWithCompletion { (session: TWTRSession!, error: NSError!) -> Void in
                    if (session != nil) {
                        Twitter.sharedInstance().APIClient.loadUserWithID(session.userID, completion: { (twtrUser: TWTRUser!,
                            error: NSError!) -> Void in
                            
                            
                            var fullNameArr = split(twtrUser.name) {$0 == " "}
                            var firstName: String = fullNameArr[0]
                            var lastName: String! = fullNameArr.count > 1 ? fullNameArr[1] : nil
                            
                            let params:[String: String] = [
                                "twitter_key" : twtrUser.userID,
                                "names" : firstName,
                                "surnames": lastName,
                                "birth_date" : "2015-01-01"
                            ]
                            
                            self.socialLogin("twitter", params: params)
                            
                        })
                        
                    } else {
                        println("error: \(error.localizedDescription)");
                    }
                    
                }
            } else {
                println("error: \(error.localizedDescription)");
            }

        }
    }

    
    
    // Facebook Delegate Methods
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        
        var userEmail = user.objectForKey("email") as! String
        println("entre aqui")
        
    
        let params:[String: String] = [
            "facebook_key" : user.objectID,
            "names" : user.first_name+" "+user.middle_name,
            "surnames":user.last_name,
            "birth_date" : "2015-01-01",
            "email": userEmail,
            "main_image":"https://graph.facebook.com/\(user.objectID)/picture?type=large"]
        
        self.socialLogin("facebook", params: params)
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    

    
    @IBAction func FBlogin(sender: UIButton) {
        if (FBSession.activeSession().state.value == FBSessionStateOpen.value || FBSession.activeSession().state.value == FBSessionStateOpenTokenExtended.value) {
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            FBSession.activeSession().closeAndClearTokenInformation()
        }
        else {
            // Open a session showing the user the login UI
            // You must ALWAYS ask for public_profile permissions when opening a session
            FBSession.openActiveSessionWithReadPermissions(["public_profile"], allowLoginUI: true, completionHandler: {
                (session: FBSession!, state: FBSessionState, error: NSError!) in
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                appDelegate.sessionStateChanged(session, state: state, error: error)
            })
        }
    }
    
    
    
    // Social login Call
    func socialLogin(type: String, params: [String:String]!){
        LoginController.loginWithSocial("http://104.236.141.44:5000/user/login/" + type, params: params){ (couponsData) -> Void in
            User.loginType = type
            let json = JSON(data: couponsData)

            let jwt = String(stringInterpolationSegment: json["token"])
            var error:NSError?
            
            User.userToken = String(stringInterpolationSegment: jwt)
            
            
            User.userImageUrl = String(stringInterpolationSegment: params["main_image"]!)
           
            //User.userEmail=String(stringInterpolationSegment:userEmail)
            //User.userName=user.username
            dispatch_async(dispatch_get_main_queue(), {
                if (!User.activeSession) {
                    self.performSegueWithIdentifier("showDashboard", sender: self)
                    User.activeSession = true
                }
            });
        }
    }
    
}
