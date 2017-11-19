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
        if let location = locations.last{
            currentLocation = location
            
            print( "Lat: " + coordinateFormatter.string(from: location.coordinate.latitude as NSNumber)! + ", Lon: " + coordinateFormatter.string(from: location.coordinate.longitude as NSNumber)!)
            
            // x: 0.0, y: 0.0, z: 5.05
            let zz = GlobeGlowPoint(lat: location.coordinate.latitude,lon: location.coordinate.longitude)
            // make this one white!
            zz.node.geometry!.firstMaterial!.diffuse.contents = "whiteGlow-32x32.png"
            earth?.addChildNode(zz.node)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
