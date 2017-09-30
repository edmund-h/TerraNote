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
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var joinedButton: UIButton!
    
    var channel: TNChannel? = nil {
        didSet {
            nameLabel.text = channel?.name ?? "no channel"
            notesLabel.text = "\(channel?.notes.count ?? 0) Notes"
            joined = channel?.members.contains(where: {$0.id == TNUser.currentUserID}) ?? false
            if joined {
                joinedButton.titleLabel?.text = "Leave"
            } else {
                joinedButton.titleLabel?.text = "Join"
            }
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
    }
    
    func setUpMembersList(with email: String? = nil) {
        var memberText = ""
        //first, check if user is a member
        if let channel = channel, channel.members.contains(where: {$0.id == TNUser.currentUserID}){
            memberText = "You, "
        }
        //then, display the first email in the member list or the sought email
        if let emailFirst = channel?.members.first?.email {
            if let email = email, emailFirst != email {
                memberText.append(email)
            } else {
                memberText.append(emailFirst)
            }
        }
        //display additional info about members if needed
        if let emailSecond = channel?.members[1].email {
            memberText.append(", \(emailSecond)")
        }
        if let count = channel?.members.count, count > 2 {
            memberText.append(", and \(count - 2) others.")
        }
    }
    
    @IBAction func joinedButtonTapped(sender: UIButton) {
        guard let channel = channel else { return }
        let notificationName = Notification.Name("ChannelCellJoinedButtonTapped")
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["id": channel.id, "joined": !joined])
        //note that the notification will pass the state that is DESIRED:
        //if the user is not in the channel, it will pass TRUE
        //if the user is leaving the channel, it will pass FALSE
    }
}
