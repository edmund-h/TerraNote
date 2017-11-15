//
//  TNChannelViewController.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/30/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation
import UIKit

class TNChannelSearchVC: UIViewController {
   
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchType: UISegmentedControl!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var newChannelButton: UIBarButtonItem!
    
    var channels: [TNChannel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "channelCell")
        
        let joinedNotification = Notification.Name("ChannelCellJoinedButtonTapped")
        let changeNotification = Notification.Name("ChannelCellNotesButtonTapped")
        
        NotificationCenter.default.addObserver(self, selector: #selector(tryJoinLeaveChannel) , name: joinedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tryChangeChannel), name: changeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changeSearchType(self)
        
    }
    
    @IBAction func newChannelButtonClicked() {
        let infoAlert = UIAlertController(title: "Add Channel", message: "Channels are a way to share notes between people. Create a channel, and anyone can search for the channel name or your email to join, see your notes, and add their own. Do not use channels to share private data!", preferredStyle: .alert)
        infoAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            let newChannelAlert = UIAlertController(title: "Add Channel", message: "Enter a name for your channel", preferredStyle: .alert )
            newChannelAlert.addTextField(configurationHandler: nil)
            newChannelAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
                newChannelAlert.dismiss(animated: true, completion: nil)
            }))
            newChannelAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                if let field = newChannelAlert.textFields?.first, let name = field.text, name != "" {
                    FirebaseClient.add(channelNamed: name)
                    newChannelAlert.dismiss(animated: true, completion: nil)
                }
                infoAlert.dismiss(animated: true, completion: {})
            }))
            self.present(newChannelAlert, animated: true, completion: nil)
        }))
        self.present(infoAlert, animated: true, completion: nil)
    }
    
    @objc func tryChangeChannel(notification: Notification) {
        if let channelID = notification.userInfo?["id"] as? String,
            let joined = notification.userInfo?["joined"] as? Bool {
            if !joined {
                let alert = UIAlertController(title: "Switch Channels", message: "You are not yet in this channel. Would you like to join in order to switch to this channel?", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    UserDefaults.standard.setValue(channelID, forKey: "currentChannel")
                    alert.dismiss(animated: true, completion: nil)
                    self.navigationController?.popToRootViewController(animated: true)
                })
                let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: {_ in
                    alert.dismiss(animated: true, completion: nil)
                })
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                UserDefaults.setValue(channelID, forKey: "currentChannel")
                navigationController?.popToRootViewController(animated: true)
            }
        } else {
            UserDefaults.setValue(nil, forKey: "currentChannel")
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func tryJoinLeaveChannel(notification: Notification) {
        if let channelID = notification.userInfo?["id"] as? String,
            let channelName = notification.userInfo?["name"] as? String,
            let joined = notification.userInfo?["joined"] as? Bool {
            let channel = TNChannel(id: channelID, name: channelName, members: [], notes: [])
            if joined {
                let alert = UIAlertController(title: "Join Channel", message: "Would you like to switch to this channel now?", preferredStyle: .alert)
                let joinSwitch = UIAlertAction(title: "Join and Switch", style: .default, handler: {_ in
                    FirebaseClient.join(channel: channel)
                    UserDefaults.standard.set(channelID, forKey: "currentChannel")
                    alert.dismiss(animated: true, completion: nil)
                    self.navigationController?.popToRootViewController(animated: true)
                })
                let join = UIAlertAction(title: "Join Only", style: .default, handler: { _ in
                    FirebaseClient.join(channel: TNChannel(id: channelID, name: channelName, members: [], notes: []))
                    alert.dismiss(animated: true, completion: nil)
                    self.tableView.reloadData()
                })
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
                    alert.dismiss(animated: true, completion: nil)
                })
                alert.addAction(joinSwitch)
                alert.addAction(join)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Leave Channel", message: "When you leave this channel, you will still be able to see your notes from this channel in 'my notes' and others in the channel will still be able to see your notes when switched to that channel. You can remove them from the channel individually.\n\nAre you sure you want to leave the channel?", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                    FirebaseClient.remove(user: TNUser.currentUserFull, fromChannel: channel)
                    alert.dismiss(animated: true, completion: nil)
                    self.tableView.reloadData()
                })
                let cancelAction = UIAlertAction(title: "No", style: .default, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                })
                alert.addAction(okAction)
                alert.addAction(cancelAction)
            }
        }
    }
    
    @IBAction func changeSearchType(_ sender: Any) {
        let index = searchType.selectedSegmentIndex
        if index == 0 {
            FirebaseClient.queryChannels(byProperty: .members, withValue: TNUser.currentUserEmail, completion: { channels in
                self.channels = channels
            })
        } else {
            self.channels = []
        }
        toggleSearchBarIfNeeded(show: index > 0)
    }
    
    func toggleSearchBarIfNeeded(show: Bool){
        var height: CGFloat = 0
        if show {
            height = 44
        }
        guard searchBarHeight.constant != height else { return }
        searchBarHeight.constant = height
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
    }
}



// MARK: TableView Functions
extension TNChannelSearchVC: UITableViewDelegate, UITableViewDataSource {
    
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

extension TNChannelSearchVC: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        var searchProperty: TNChannel.Property = .members
        if searchType.selectedSegmentIndex == 1 {
            searchProperty = .name
        }
        FirebaseClient.queryChannels(byProperty: searchProperty, withValue: text, completion: {channels in
            self.channels = channels
        })
    }
}
