//
//  SigninController.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/5/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class TNSignInController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var googleButton: GIDSignInButton!
    
    var blockList: [TNUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().shouldFetchBasicProfile  = true
        
    }
}


extension TNSignInController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print (error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let email = user?.email, let uid = user?.uid {
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.set(uid, forKey: "uid")
                let emailkey =  TNUser.Property.email.rawValue
                Database.database().reference().child("users").child(uid).child(emailkey).setValue(email)
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        //TODO: nuke userdefaults
    }
    
}

