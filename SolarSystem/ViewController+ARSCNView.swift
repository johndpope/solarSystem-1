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
    
    static var runOnce = false
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        if let cc = MyCameraCoordinates.getCameraCoordinates(sceneView: sceneView){
                print("actual iphone camera position:",cc.friendlyString())
            print("camera node position:",cameraNode.worldPosition.friendlyString())
            
            
        }

        

    }
    
    func focusOnEarth(){

        
        sceneView.pointOfView?.position = cameraHandle.position 
   
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        print(node)
        
      
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    func recenterEarthToPositionOfCamera(_ renderer:SCNSceneRenderer, _ scene: SCNScene){
        // The node provides the position and direction of a virtual camera, and the camera object provides rendering parameters such as field of view and focus.
        guard let pointOfView = renderer.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = orientation + location

        
        
        DispatchQueue.main.async {
            if let earthPosition = self.earth?.position{
                let earthOffset = earthPosition - currentPositionOfCamera
                self.cameraHandle.position = earthOffset
                //self.cameraHandle.orientation = orientation
                self.sceneView.pointOfView = self.cameraNode
            }
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
       // recenterEarthToPositionOfCamera(renderer,scene)
    }

}
