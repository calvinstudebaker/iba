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

/**
Where all the networking calls are situated. Uses parse cloud code.
*/
class IBANetworking {
    
    /**
    Gets all the values (crimes, prices, or tickets) for a particular GMSVisibleRegion
    
    :param: region The GMSVisibleRegion you want to get values for
    :param: values The string type of value you want ("crimes", "prices", or "tickets")
    :param: completion The PFIdResultBlock you'd like to have called upon completion
    */
    class func valuesInRegion(region: GMSVisibleRegion, values: String, completion: PFIdResultBlock) {
        
        let nearLeft = PFGeoPoint(latitude: region.nearLeft.latitude, longitude: region.nearLeft.longitude)
        let nearRight = PFGeoPoint(latitude: region.nearRight.latitude, longitude: region.nearRight.longitude)
        let farLeft = PFGeoPoint(latitude: region.farLeft.latitude, longitude: region.farLeft.longitude)
        let farRight = PFGeoPoint(latitude: region.farRight.latitude, longitude: region.farRight.longitude)
        
        let parameters = ["nearLeft": nearLeft, "nearRight": nearRight, "farLeft": farLeft, "farRight": farRight]
        
        PFCloud.callFunctionInBackground(values + "InRegion", withParameters: parameters, block: completion)
        
    }
    
    /**
    Submits a report for a given parking spot
    
    :param: report The Dictionary of information included in the report
    :param: completion The PFBooleanResultBlock you'd like called after completion
    */
    class func submitReport(report: [String: AnyObject!], completion: PFBooleanResultBlock) {
        
        let uGenReport = PFObject(className: "UserGeneratedReport")
        
        let location: CLLocation = report["location"] as! CLLocation
        
        uGenReport["type"] = report["reportType"] as! String
        uGenReport["damageRating"] = NSNumber(float: report["damagePercent"] as! Float)
        uGenReport["easeRating"] = NSNumber(float: report["easePercent"] as! Float)
        uGenReport["priceRating"] = NSNumber(float: report["spotPricePercent"] as! Float)
        uGenReport["ticketCost"] = NSNumber(float: report["ticketPricePercent"] as! Float)
        uGenReport["location"] = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        uGenReport["installation"] = PFInstallation.currentInstallation()
        uGenReport.saveInBackgroundWithBlock(completion)
        
    }
    
    /**
    Documents every instance of users sharing the app in parse
    
    :param: type The method the user used to share the app
    :param: completion The PFBooleanResultBlock you'd like to have called upon completion
    */
    class func shareHit(type: String, completion: PFBooleanResultBlock) {
        let share = PFObject(className: "Share");
        share["type"] = type;
        share["installation"] = PFInstallation.currentInstallation()
        share.saveInBackgroundWithBlock(completion);
    }
    
    /**
    Search for a destination via String. Uses Google Maps api to form a query
    
    :param: destination The String destination you are searching for
    :param: completion The custom block to be called upon completion
    */
    class func searchForDestination(destination: String, completion: (complete: Bool, location: CLLocation?) -> ()) {
        
        let queryString: String = (("https://maps.googleapis.com/maps/api/place/textsearch/json?query=" + destination + "&key=AIzaSyAbd-ELe3MBV2eYyJ3AKCoZuRut7kcWLW0") as NSString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) as String!
        
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