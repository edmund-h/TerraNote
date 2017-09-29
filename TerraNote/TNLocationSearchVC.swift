//
//  TNLocationSearchVC.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/29/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation
import UIKit

class TNLocationSearchVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UITextField!
    
    var completions: [String] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "completionCell")
        searchBar.delegate = self
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.becomeFirstResponder()
    }
}

extension TNLocationSearchVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let searchText = textField.text, searchText.characters.count > 4 {
            CoreLocClient.forwardGeocodeAutoCompletions(text: searchText, completion: { autoCompletions in
                self.completions = autoCompletions
            })
        }
        return true
    }
    
}

extension TNLocationSearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = completions[indexPath.row]
        cell.contentView.layer.cornerRadius = 9
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notificationName = NSNotification.Name.init("mapViewChangeLocation")
        let location = completions[indexPath.row]
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["location":location])
        self.dismiss(animated: true, completion: nil)
    }
}
