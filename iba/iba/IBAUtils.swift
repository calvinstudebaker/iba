//
//  IBAUtils.swift
//  iba
//
//  Created by Raymond Kennedy on 3/8/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import Foundation

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}