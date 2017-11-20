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
              //  self?.earth?.orientation = SCNQuaternion(q.x, q.y, q.z, -q.w)

            }
        }
    }
}
