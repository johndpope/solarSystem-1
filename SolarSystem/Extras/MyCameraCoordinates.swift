//
//  CameraCoordinates.swift
//  HelloARWorld
//
//  Created by ben on 29/10/2017.
//  Copyright © 2017 ben. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

struct MyCameraCoordinates {
    var x = Float()
    var y = Float()
    var z = Float()
    
    func getCameraCoordinates(sceneView: ARSCNView) -> MyCameraCoordinates {
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let cameraCoordinates = MDLTransform(matrix: cameraTransform!)
        
        var cc = MyCameraCoordinates()
        cc.x = cameraCoordinates.translation.x
        cc.y = cameraCoordinates.translation.y
        cc.z = cameraCoordinates.translation.z
        
        return cc
    }
}
