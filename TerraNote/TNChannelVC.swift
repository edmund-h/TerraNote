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
        }
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
