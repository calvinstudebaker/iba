//
//  IBAButton.swift
//  iba
//
//  Created by Raymond kennedy on 4/8/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import UIKit

class IBAButton : UIButton {
    
    let mainColor: UIColor
    
    convenience init(frame: CGRect, title: String, colorScheme: UIColor) {
        self.init(frame: frame)
        
        self.setTitle(title, forState: .Normal)
        self.backgroundColor = UIColor.clearColor()
        
        self.layer.cornerRadius = 6.0
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.25
        self.layer.borderColor = colorScheme.CGColor
        self.setTitleColor(colorScheme, forState: .Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
    }
    
    override init(frame: CGRect) {
        
        self.mainColor = UIColor.blackColor()
        super.init(frame: frame)
        
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var highlighted: Bool {
        willSet(newValue) {
            if (newValue) {
                self.backgroundColor = UIColor(CGColor: self.layer.borderColor)
            } else {
                self.backgroundColor = UIColor.clearColor()
            }
        }
        
        didSet {

        }
    }
    
}
