//
//  MovingAlertViewController.swift
//  iba
//
//  Created by Raymond Kennedy on 3/8/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import UIKit

class MovingAlertViewController: UIViewController {
    
    var ignoreButton: UIButton;
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience override init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        ignoreButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ignoreButton.frame = CGRectMake(100, 100, self.view.bounds.size.width, self.view.bounds.size.height/2);
        self.view.addSubview(ignoreButton);
        
        self.view.backgroundColor = UIColor.greenColor()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
