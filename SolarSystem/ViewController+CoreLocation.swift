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
        locationManager.headingFilter = 5
        locationManager.startUpdatingHeading()
        
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
    
    func locationManagerDidUpdateHeading(trueHeading: CLLocationDirection, magneticHeading: CLLocationDirection, accuracy: CLLocationDirection) {
        self.heading = Float(trueHeading)
    }
    

   /* func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {

        if newHeading.headingAccuracy > 0 {

            print(newHeading.trueHeading)
            let headingD = newHeading.trueHeading
            self.heading = Float(headingD)
       
            
                self.earth?.orientation = SCNQuaternion(q.x, q.y, q.z, -q.w)
                celestialEquatorTilt.eulerAngles = SCNVector3(x: Float(23.5), y: 0.0, z: 0)
          
            
        }

    }*/
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        
        return true
        
    }
}

//MARK: Correct User and friends' view
// rotate x-axis (camera node) according to acceleration
//將最原始起始視角換成春分點//
/*private func orientationFromCMQuaternion(cmQ: CMQuaternion, headingQ: Float) -> SCNVector4 {
    let gq1 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(Float(rotateDegreeCameraX) - 90), 1, 0, 0)
    let gq3 = GLKQuaternionMake(Float(cmQ.x), Float(cmQ.y), Float(cmQ.z), Float(cmQ.w))
    let gq2 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 0, 1)
    
    //!!問題：相機node的校正尚有一些問題!!//
    let gq4 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(headingQ), 0, 0, 1)
    let qp = GLKQuaternionMultiply(gq1, gq2)
    let qp2 = GLKQuaternionMultiply(qp, gq4)
    let qp3 = GLKQuaternionMultiply(qp2, gq3)
    let rq = CMQuaternion(x: Double(qp3.x), y: Double(qp3.y), z: Double(qp3.z), w: Double(qp3.w))
    return SCNVector4Make(Float(rq.x), Float(rq.y), Float(rq.z), Float(rq.w))
}*/

class Calc {
    static func getPosition(trueHeading: Double, distance: Double, y: Double) -> SCNVector3 {
        let angle = trueHeading + 90.0
        let radian = Double.pi / 180 * Double(angle)
        let x = cos(radian) * distance
        let z = (sin(radian) * distance) * -1
        return SCNVector3(x, y, z)
    }
}

extension CLLocation {
    // 方角の取得
    func angle(to: CLLocation) -> Double {
        let longitudeDifference = to.coordinate.longitude - coordinate.longitude
        let latitudeDifference  = to.coordinate.latitude - coordinate.latitude
        var azimuth = (Double.pi * 0.5) - atan(latitudeDifference / longitudeDifference);
        
        if longitudeDifference > 0 {
        } else if longitudeDifference < 0 {
            azimuth += Double.pi
        } else if latitudeDifference < 0 {
            azimuth = Double.pi
        } else {
            azimuth = 0
        }
        return azimuth * 360 / (Double.pi * 2)
    }
}

