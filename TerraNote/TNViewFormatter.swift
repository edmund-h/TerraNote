//
//  TNViewFormatter.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/6/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation
import FTPopOverMenu_Swift

class TNViewFormatter {
    
    class func formatTableCell (_ cell: UITableViewCell ){
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.chocolate.cgColor
        cell.textLabel?.textColor = UIColor.chocolate
        cell.detailTextLabel?.textColor = UIColor.chocolate
    }
    
    class func formatView (_ field: UIView){
        field.layer.borderWidth = 3
        field.layer.cornerRadius = 9
        field.layer.borderColor = UIColor.chocolate.cgColor
    }
    
    class func formatButton (_ button: UIButton){
        button.layer.cornerRadius = 9
        button.backgroundColor = UIColor.chocolate
        button.setTitleColor( UIColor.white, for: .normal)
    }
    
    class func formatLabel (_ label: UILabel){
        label.textColor = UIColor.chocolate
        label.numberOfLines = 0
    }
    
    class func setPopoverFormat (){
        let config = FTConfiguration.shared
        config.backgoundTintColor = UIColor.mapChoco
        let height = config.menuRowHeight
        config.menuRowHeight = height * 0.9
    }
    
    class func pinHitbox (_ view: MKAnnotationView)->UIView{
        let pinHitboxView = UIView()
        view.addSubview(pinHitboxView)
        pinHitboxView.translatesAutoresizingMaskIntoConstraints = false
        pinHitboxView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45).isActive = true
        pinHitboxView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        pinHitboxView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pinHitboxView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        return pinHitboxView
    }
    
}//contains functions to format the views

extension UIColor{
    static let chocolate = UIColor(colorLiteralRed: 105/255.0, green: 71/255.0, blue: 56/255.0, alpha: 1)
    static let mapChoco = UIColor(colorLiteralRed: 125/255.0, green: 91/255.0, blue: 76/255.0, alpha: 1)
}//contains a visually appealing custom brown color for aesthetic unity
