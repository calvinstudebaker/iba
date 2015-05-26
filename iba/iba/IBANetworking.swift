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
    
    class func valuesInRegion(region: GMSVisibleRegion, values: String, completion: PFIdResultBlock) {
        
        let nearLeft = PFGeoPoint(latitude: region.nearLeft.latitude, longitude: region.nearLeft.longitude)
        let nearRight = PFGeoPoint(latitude: region.nearRight.latitude, longitude: region.nearRight.longitude)
        let farLeft = PFGeoPoint(latitude: region.farLeft.latitude, longitude: region.farLeft.longitude)
        let farRight = PFGeoPoint(latitude: region.farRight.latitude, longitude: region.farRight.longitude)
        
        let parameters = ["nearLeft": nearLeft, "nearRight": nearRight, "farLeft": farLeft, "farRight": farRight]
        
        PFCloud.callFunctionInBackground(values + "InRegion", withParameters: parameters, block: completion)
        
    }
    
    class func submitReport(report: [String: AnyObject!], completion: PFBooleanResultBlock) {
        
        let uGenReport = PFObject(className: "UserGeneratedReport")
        
        let location: CLLocation = report["location"] as! CLLocation
        
        uGenReport["damageRating"] = NSNumber(float: report["damagePercent"] as! Float)
        uGenReport["easeRating"] = NSNumber(float: report["easePercent"] as! Float)
        uGenReport["priceRating"] = NSNumber(float: report["spotPricePercent"] as! Float)
        uGenReport["ticketCost"] = NSNumber(float: report["ticketPricePercent"] as! Float)
        uGenReport["location"] = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        uGenReport["installation"] = PFInstallation.currentInstallation()
        uGenReport.saveInBackgroundWithBlock(completion)
        
    }
    
    class func shareHit(type: String, completion: PFBooleanResultBlock) {
        let share = PFObject(className: "Share");
        share["type"] = type;
        share["installation"] = PFInstallation.currentInstallation()
        share.saveInBackgroundWithBlock(completion);
    }
    
    class func searchForDestination(destination: String, completion: (complete: Bool, location: CLLocation?) -> ()) {
        
        let queryString: String = (("https://maps.googleapis.com/maps/api/place/textsearch/json?query=" + destination + "&key=AIzaSyAbd-ELe3MBV2eYyJ3AKCoZuRut7kcWLW0") as NSString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) as String!
        println("Search Query: " + queryString)
        
        let manager = AFHTTPRequestOperationManager()
        manager.GET(queryString,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> () in
                
                let dict: [String: AnyObject] = responseObject as! [String: AnyObject]
                
                // Get the location and return it
                if let results = dict["results"] as? [AnyObject] {
                    if (results.count > 0) {
                        if let result = results[0] as? [String: AnyObject] {
                            if let geometry = result["geometry"] as? [String: AnyObject] {
                                if let location = geometry["location"] as? [String: AnyObject] {
                                    let lat: Double = location["lat"] as! Double
                                    let lng: Double = location["lng"] as! Double
                                    let location: CLLocation = CLLocation(latitude: lat, longitude: lng)
                                    completion(complete: true, location: location)
                                    return
                                    
                                }
                            }
                        }
                    }
                    
                }
                completion(complete: false, location: nil)
                
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> () in
                completion(complete: false, location: nil)
                
            }
        )
        
        
    }
    
}