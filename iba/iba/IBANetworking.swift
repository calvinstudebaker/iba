//
//  IBANetworking.swift
//  iba
//
//  Created by Raymond Kennedy on 3/8/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import Foundation
import Parse
import CoreLocation

class IBANetworking {
    
    func crimesNearLocation(#location: CLLocationCoordinate2D, completion: PFIdResultBlock) {
        
        let geoPoint = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        let parameters = ["location": geoPoint]
        
        PFCloud.callFunctionInBackground("getCrimesNearLocation", withParameters: parameters, block: completion)
        
    }
    
}