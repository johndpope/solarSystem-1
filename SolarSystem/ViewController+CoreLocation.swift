//
//  ViewController.swift
//  SolarSystem
//
//  Created by Robert Kim on 7/15/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreMotion
import CoreLocation


let coordinateFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 2
    return formatter
}()

extension ViewController:CLLocationManagerDelegate{
    
    // MARK: Location manager
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status != .authorizedWhenInUse || status != .authorizedAlways else {
            return
        }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         let location = locations.last!
        currentLocation = location
       
        print( "Lat: " + coordinateFormatter.string(from: location.coordinate.latitude as NSNumber)! + ", Lon: " + coordinateFormatter.string(from: location.coordinate.longitude as NSNumber)!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
