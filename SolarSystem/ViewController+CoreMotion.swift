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

extension ViewController{
    func listenForCoreMotionChanges(){
        moMan.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: OperationQueue.main) { [weak self] (motion, error) in
            if let q = motion?.attitude.quaternion {
                
               // self?.celestialEquatorTilt.eulerAngles = SCNVector3(x:Float(q.x), y: 0.0, z: 0)
                
                //if let o = self?.earth?.orientation{
                   // self?.scene.rootNode.orientation  = SCNQuaternion(q.x, q.y, q.z, q.w)
               // }
                
              //
            }
        }
    }
}
