//
//  TNChannelViewController.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/30/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation
import UIKit

class TNChannelVC: UIViewController {
   
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchAreaHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchType: UISegmentedControl!
    
    @IBOutlet weak var newChannelButton: UIBarButtonItem!
    
    var channels: [TNChannel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var searchMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "channelCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if searchMode == false {
            searchAreaHeight.constant = 0
            FirebaseClient.queryChannels(byProperty: .members, withValue: TNUser.currentUserEmail, completion: { channels in
                self.channels = channels
            })
        } else {
            newChannelButton.tintColor = UIColor.clear
            newChannelButton.isEnabled = false
        }
    }
    
    @IBAction func newChannelButtonClicked() {
        guard self.searchMode == false else {return}
        let infoAlert = UIAlertController(title: "Add Channel", message: "Channels are a way to share notes between people. Create a channel, and anyone can search for the channel name or your email to join, see your notes, and add their own. Do not use channels to share private data!", preferredStyle: .alert)
        infoAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            let newChannelAlert = UIAlertController(title: "Add Channel", message: "Enter a name for your channel", preferredStyle: .alert )
            newChannelAlert.addTextField(configurationHandler: nil)
            newChannelAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in newChannelAlert.dismiss(animated: true, completion: nil)}))
            newChannelAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                if let field = newChannelAlert.textFields?.first, let name = field.text, name != "" {
                    FirebaseClient.add(channelNamed: name)
                    newChannelAlert.dismiss(animated: true, completion: nil)
                }
            }))
            infoAlert.dismiss(animated: true, completion: {self.present(newChannelAlert, animated: true, completion: nil) })
        }))
        self.present(infoAlert, animated: true, completion: nil)
    }
}

// MARK: TableView Functions
extension TNChannelVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let info = TNChannelCellView()
        info.channel = channels[indexPath.row]
        info.addAndConstrainTo(view: cell.contentView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
