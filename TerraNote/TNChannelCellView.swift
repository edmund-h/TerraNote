//
//  TNChannelCell.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/30/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation
import UIKit

class TNChannelCellView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var infoArea: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var joinedButton: UIButton!
    
    var channel: TNChannel? = nil {
        didSet {
            nameLabel.text = channel?.name ?? "no channel"
            
            notesButton.setTitle("\(channel?.notes.count ?? 0) Notes", for: .normal)
            
            joined = channel?.members.contains(where: {$0.id == TNUser.currentUserID}) ?? false
            var buttonTitleText: String
            if joined {
                buttonTitleText = "Leave"
            } else {
                buttonTitleText = "Join"
            }
            
            joinedButton.setTitle(buttonTitleText, for: .normal)
            setUpMembersList()
        }
    }
    var joined: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("TNChannelCellView", owner: self, options: nil)
        
        contentView.addAndConstrainTo(view: self)
        infoArea.layer.cornerRadius = 5
        joinedButton.layer.cornerRadius = 5
        
        notesButton.layer.borderWidth = 2
        notesButton.layer.borderColor = UIColor.white.cgColor
        notesButton.layer.cornerRadius = 5
    }
    
    func setUpMembersList(with email: String? = nil) {
        var memberText = ""
        //first, check if user is a member
        guard let channel = channel else { return }
        let memberCount = channel.members.count
        if channel.members.contains(where: {$0.id == TNUser.currentUserID}){
            memberText = "You"
            if memberCount > 1 {memberText.append(", ")}
        }
        //then, display the first email in the member list or the sought email
        if let emailFirst = channel.members.first?.email,
            emailFirst != TNUser.currentUserEmail {
            if let email = email, emailFirst != email {
                memberText.append(email)
            } else {
                memberText.append(emailFirst)
            }
        }
        //display additional info about members if needed
        if memberCount > 1{
            let emailSecond = channel.members[1].email
            memberText.append(", \(emailSecond)")
        }
        if memberCount > 2 {
            memberText.append(", and \(memberCount - 2) more.")
        }
        
        membersLabel.text = memberText
    }
    
    @IBAction func joinedButtonTapped(sender: UIButton) {
        guard let channel = channel else { return }
        let notificationName = Notification.Name("ChannelCellJoinedButtonTapped")
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["id": channel.id, "name": channel.name, "joined": !joined])
        //note that the notification will pass the state that is DESIRED:
        //if the user is not in the channel, it will pass TRUE
        //if the user is leaving the channel, it will pass FALSE
    }
    
    @IBAction func notesButtonTapped(sender: UIButton) {
        guard let channel = channel else { return }
        let notificationName = Notification.Name("ChannelCellNotesButtonTapped")
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["id": channel.id, "joined": joined])
        //note that the notification will pass the CURRENT STATE
        //if the user is in the channel it will pass TRUE
        //if the user is not in the chennel it will pass FALSE
    }
}
