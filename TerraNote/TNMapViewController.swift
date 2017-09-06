//
//  ViewController.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/5/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import UIKit

class TNMapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let signIn = TNSignInController()
        self.present(signIn, animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

