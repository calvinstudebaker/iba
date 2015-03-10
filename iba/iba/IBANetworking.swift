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
    
    class func crimesInBoxWithCorners(southwest: CLLocationCoordinate2D, northeast: CLLocationCoordinate2D, completion: PFIdResultBlock) {
        
        let southwestPoint = PFGeoPoint(latitude: southwest.latitude, longitude: southwest.longitude)
        let northeastPoint = PFGeoPoint(latitude: northeast.latitude, longitude: northeast.longitude)
        
        println("Searching for crimes in bounds: ")
        println("\tSouthwest: (\(southwestPoint.latitude), \(southwestPoint.longitude))")
        println("\tNortheast: (\(northeastPoint.latitude), \(northeastPoint.longitude))")
        let parameters = ["southwest": southwestPoint, "northeast": northeastPoint]
        
        PFCloud.callFunctionInBackground("getCrimesInBoundingBox", withParameters: parameters, block: completion)
        
    }
    
}