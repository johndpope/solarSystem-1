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
        //recenterEarthToPositionOfCamera(renderer,scene)
        
//        if !ViewController.runOnce{
//            //guard let pointOfView = renderer.pointOfView else { return }
//            if let cc = camCoords.getCameraCoordinates(sceneView: sceneView){
//                if cc.x == 0{
//                    return;
//                }
//                ViewController.runOnce = true
//                createEnvironment(cameraPosition:SCNVector3(cc.x, cc.y, cc.z))
//                //node.position = SCNVector3(cc.x, cc.y, cc.z)
//                //sceneView.scene.rootNode.addChildNode(node)
//            }
//        }
    }
    
    func focusOnEarth(){
        
        /* if (cameraNode != sceneView.pointOfView){
         print("👀 - making cameraNode the sceneView.pointOfView ")
         sceneView.pointOfView = cameraNode
         }*/
        
        // zoom to user's location
        
        sceneView.pointOfView?.position = cameraHandle.position
        //            sceneView.pointOfView?.rotation = cameraHandle.rotation
        
        //        sceneView.pointOfView?.position = zoomedOutEarthCameraPosition!
        /*sceneView.pointOfView?.position = cameraHandle.presentation.position
         sceneView.pointOfView?.rotation = cameraHandle.presentation.rotation
         sceneView.pointOfView?.orientation = cameraHandle.presentation.orientation*/
        //        }
        
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
