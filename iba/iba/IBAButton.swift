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
    var clear: Bool
    
    convenience init(frame: CGRect, title: String, colorScheme: UIColor, clear: Bool) {
        self.init(frame: frame)
        
        self.setTitle(title, forState: .Normal)
        if (clear) {
            self.backgroundColor = UIColor.clearColor()
        } else {
            self.backgroundColor = UIColor.whiteColor()
        }
        
        self.layer.cornerRadius = 6.0
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.25
        self.layer.borderColor = colorScheme.CGColor
        self.setTitleColor(colorScheme, forState: .Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        self.clear = clear
    }
    
    override init(frame: CGRect) {
        
        self.clear = true
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
                if (self.clear) {
                    self.backgroundColor = UIColor.clearColor()
                } else {
                    self.backgroundColor = UIColor.whiteColor()
                }
            }
        }
        
        didSet {

        }
    }
    
}
