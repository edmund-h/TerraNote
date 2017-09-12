//
//  TNSearchTableVC.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/12/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import UIKit

class TNSearchTableVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentHeight: NSLayoutConstraint!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var notes: [TNNote] = []
    var showSearch = true
    
    var properties: [TNProperty] = [.title, .location, .date, .content]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segment.selectedSegmentIndex = 0
        for index in 0..<properties.count {
            segment.setTitle(properties[index].rawValue, forSegmentAt: index)
        }
        searchBar.returnKeyType = .done
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if showSearch == false {
            searchBarHeight.constant = 0
            searchBar.isHidden = true
            segmentHeight.constant = 0
            segment.isHidden = true
            view.layoutSubviews()
            tableView.reloadData()
        }
        super.viewWillAppear(animated)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "note", let destination = segue.destination as? TNNewNoteVC, let indexPath = tableView.indexPathForSelectedRow{
            destination.note = notes[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}

extension TNSearchTableVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if segment.selectedSegmentIndex == 2 {
            // bring up datepicker if not already up
            return false
        }
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let text = searchBar.text else {return}
        searchBar.text = nil
        let selected = segment.selectedSegmentIndex
        FirebaseClient.query(by: properties[selected], with: text, completion: { notes in
            self.notes = notes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func segmentTouched(){
        if segment.selectedSegmentIndex == 2 {
            searchBar.resignFirstResponder()
            searchBar.text = nil
            // bring up datepicker
        }
    }
}

extension TNSearchTableVC: UITableViewDelegate, UITableViewDataSource {
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
}
