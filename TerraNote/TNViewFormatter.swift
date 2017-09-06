//
//  TNViewFormatter.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/6/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation

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
    
}//contains functions to format the views

extension UIColor{
    static let chocolate = UIColor(colorLiteralRed: 90/255.0, green: 71/255.0, blue: 56/255.0, alpha: 1)
}//contains a visually appealing custom brown color for aesthetic unity
