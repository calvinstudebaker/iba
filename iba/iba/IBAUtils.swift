//
//  IBAUtils.swift
//  iba
//
//  Created by Raymond Kennedy on 3/8/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import Foundation

let PARKED_LOCATION_LAT = "parkedLocationLatitude"
let PARKED_LOCATION_LON = "parkedLocationLongitude"
let PARKING_METER_END_DATE = "parkingMeterEndDate"
let CAR_STATUS_CHANGED = "carStatusChanged"

let DEFAULT_ZOOM = 16

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

extension String
{
    subscript(i: Int) -> Character {
        return self[advance(startIndex, i)]
    }
    
    subscript(range: Range<Int>) -> String {
        return self[advance(startIndex, range.startIndex)..<advance(startIndex, range.endIndex)]
    }
}