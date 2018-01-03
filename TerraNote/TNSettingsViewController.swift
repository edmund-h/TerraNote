//
//  SettingsViewController.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 1/3/18.
//  Copyright © 2018 Bozo Design Labs. All rights reserved.
//

import UIKit

class TNSettingsViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var blockList: [TNUser] = []
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
}

extension TNSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if blockList.isEmpty {
            return 1
        }
        return blockList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if blockList.isEmpty {
            cell.textLabel?.text = "No blocked users."
        } else {
            cell.textLabel?.text = blockList[indexPath.row].email
        }
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
