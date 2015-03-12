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
    
    class func crimesInRegion(region: GMSVisibleRegion, completion: PFIdResultBlock) {
        
        let nearLeft = PFGeoPoint(latitude: region.nearLeft.latitude, longitude: region.nearLeft.longitude)
        let nearRight = PFGeoPoint(latitude: region.nearRight.latitude, longitude: region.nearRight.longitude)
        let farLeft = PFGeoPoint(latitude: region.farLeft.latitude, longitude: region.farLeft.longitude)
        let farRight = PFGeoPoint(latitude: region.farRight.latitude, longitude: region.farRight.longitude)
        
        let parameters = ["nearLeft": nearLeft, "nearRight": nearRight, "farLeft": farLeft, "farRight": farRight]
        
        PFCloud.callFunctionInBackground("crimesInRegion", withParameters: parameters, block: completion)
        
    }
    
}