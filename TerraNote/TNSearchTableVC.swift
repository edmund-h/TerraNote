//
//  TNSearchTableVC.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/12/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import UIKit

class TNSearchTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentHeight: NSLayoutConstraint!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var notes: [TNNote] = []
    
    enum searchMode {
        case date, location, title, content
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if notes.count > 0 {
            searchBarHeight.constant = 0
            searchBar.isHidden = true
            segmentHeight.constant = 0
            segment.isHidden = true
            view.layoutSubviews()
            tableView.reloadData()
        }
        super.viewWillAppear(animated)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].title
        if let date = Date.from(iso8601: notes[indexPath.row].date){
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            cell.detailTextLabel?.text = dateFormatter.string(from: date)
        }
        return cell
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "note", let destination = segue.destination as? TNNewNoteVC, let index = tableView.indexPathForSelectedRow?.row{
            destination.note = notes[index]
        }
     }
 
}
