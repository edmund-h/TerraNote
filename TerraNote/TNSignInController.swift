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
    @IBOutlet weak var settingsContainerView: UIView!
    @IBOutlet weak var settingsContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    
    var blockList: [TNUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().shouldFetchBasicProfile  = true
        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == false {
            settingsContainerHeight.constant = 90
            settingsContainerView.isHidden = false
            settingsContainerView.subviews.forEach({$0.isUserInteractionEnabled = false})
        }
        if let blockData = UserDefaults.standard.dictionary(forKey: TNUser.Property.blocklist.rawValue) as? [String:String] {
            blockData.forEach({key, value in
                blockList.append(TNUser(email: value, id: key, channels: [], blocklist: [], notes: []))
            })
        }
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

extension TNSignInController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = blockList[indexPath.row].email
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let confirmUnblockAlert = UIAlertController(title: "Unblock User", message: "Would you like to unblock this user?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: {_ in
            FirebaseClient.unblock(self.blockList[indexPath.row])
            tableView.reloadData()
        })
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: {_ in confirmUnblockAlert.dismiss(animated: true, completion: nil)})
        confirmUnblockAlert.addAction(yesAction)
        confirmUnblockAlert.addAction(noAction)
        self.present(confirmUnblockAlert, animated: true, completion: nil)
    }
}
