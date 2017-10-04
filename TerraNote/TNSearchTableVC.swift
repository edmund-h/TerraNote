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
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var cancelPicker: UIButton!
    @IBOutlet weak var donePicker: UIButton!
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var pickerConstraint: NSLayoutConstraint!
    
    var notes: [TNNote.Short] = []
    var showSearch = true
    var pickerUp = false
    var pickerDate: Date? = nil
    
    var properties: [TNNote.Property] = [.title, .location, .date, .content]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segment.selectedSegmentIndex = 0
        for index in 0..<properties.count {
            segment.setTitle(properties[index].rawValue, forSegmentAt: index)
        }
        searchBar.returnKeyType = .done
        searchBar.delegate = self
        TNViewFormatter.formatButton(cancelPicker)
        TNViewFormatter.formatButton(donePicker)
        picker.setValue(UIColor.white, forKey: "textColor")
        let height = pickerContainer.frame.height
        pickerConstraint.constant = -1 * (height)
        pickerContainer.isHidden = true
        pickerContainer.subviews.forEach({
            $0.isHidden = true
            $0.isUserInteractionEnabled = false
        })
        view.layoutSubviews()
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
    
    @IBAction func cancelPicker(_ sender: Any) {
        toggleDatePicker(show: false)
        searchBar.text = nil
    }
    
    @IBAction func donePicker(_ sender: Any) {
        searchBarSearchButtonClicked(searchBar)
        toggleDatePicker(show: false)
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        pickerDate = picker.date
        searchBar.text = dateformatter.string(from: pickerDate!)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "note", let destination = segue.destination as? TNNewNoteVC, let indexPath = tableView.indexPathForSelectedRow{
            destination.noteShort = notes[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func toggleDatePicker(show: Bool){
        if pickerContainer.isHidden == true {
            pickerContainer.isHidden = false
            pickerContainer.subviews.forEach({
                $0.isHidden = false
                $0.isUserInteractionEnabled = true
            })
        }
        let height = pickerContainer.frame.height
        if show {
            picker.isHidden = false
            pickerConstraint.constant = 0
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            pickerConstraint.constant = -1 * (height)
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            }, completion:{ done in
                self.picker.isHidden = true
            })
        }
    }
    
    
}

extension TNSearchTableVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if segment.selectedSegmentIndex == 2 {
            toggleDatePicker(show: true)
            return false
        }
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard var text = searchBar.text else {return}
        searchBar.text = nil
        let selected = segment.selectedSegmentIndex
        if selected == 2,
            let date = pickerDate {
            text = date.toISO8601()
        }
        FirebaseClient.queryNotes(by: properties[selected], with: text, completion: { notes in
            self.notes = notes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func segmentHighlighted(){
        print("yo")
        if segment.selectedSegmentIndex == 2 {
            searchBar.resignFirstResponder()
            searchBar.text = nil
            toggleDatePicker(show: true)
        } else {
            toggleDatePicker(show: false)
            searchBar.becomeFirstResponder()
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
