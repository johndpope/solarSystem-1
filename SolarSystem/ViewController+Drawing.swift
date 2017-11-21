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
    
    func spinAnimation(duration: Double) -> CABasicAnimation {
        
        let spin = CABasicAnimation(keyPath: "rotation")
        
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float(2 * CGFloat.pi)))
        spin.duration = duration
        spin.repeatCount = .infinity
        
        return spin
    }
    
    
    func addNodeToSceneView(node:SCNNode,at position: SCNVector3){
        node.position = position
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func addNodeToPointOfView(node:SCNNode){
        self.sceneView.pointOfView?.addChildNode(node)
    }
    
    func addNodeAtCameraPosition(node:SCNNode){
        if let cc = MyCameraCoordinates.getCameraCoordinates(sceneView: sceneView){
            node.position = SCNVector3(cc.x, cc.y, cc.z)
            sceneView.scene.rootNode.addChildNode(node)
        }
        
    }
    
    func placeNodeInfrontOfCamera(node:SCNNode) {
        let pointOfView = self.sceneView.pointOfView
        node.simdPosition = pointOfView!.simdPosition + (pointOfView?.simdWorldFront)! * 2
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    
    
    func constrainCameraToPlanetNode(_ node:SCNNode){
        cameraNode.constraints = [ SCNLookAtConstraint(target: node) ]
    }
    
    func addNorthSouthPoles(node:SCNNode){
        let northPole = GlobeGlowPoint(lat: 90,lon: 0)
        let southPole = GlobeGlowPoint(lat: -90,lon: 0)
        let line = cylinderLineBetweenNodeA(nodeA:northPole.node,nodeB:southPole.node)
        
        node.addChildNode(line)
    }
    
    func cylinderLineBetweenNodeA(nodeA: SCNNode, nodeB: SCNNode) -> SCNNode {
        
        return CylinderLine(parent: sceneView.scene.rootNode,
                            v1: nodeA.position,
                            v2: nodeB.position,
                            radius: 0.001,
                            radSegmentCount: 16,
                            color: UIColor.red)
        
    }
    

    
     func lineBetweenNodeA(nodeA: SCNNode, nodeB: SCNNode) -> SCNNode {
        let positions: [Float32] = [nodeA.position.x, nodeA.position.y, nodeA.position.z, nodeB.position.x, nodeB.position.y, nodeB.position.z]
        let positionData = NSData(bytes: positions, length: MemoryLayout<Float32>.size*positions.count)
        let indices: [Int32] = [0, 1]
        let indexData = NSData(bytes: indices, length: MemoryLayout<Int32>.size * indices.count)
        
        let source = SCNGeometrySource(data: positionData as Data, semantic: SCNGeometrySource.Semantic.vertex, vectorCount: indices.count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<Float32>.size, dataOffset: 0, dataStride: MemoryLayout<Float32>.size * 3)
        let element = SCNGeometryElement(data: indexData as Data, primitiveType: SCNGeometryPrimitiveType.line, primitiveCount: indices.count, bytesPerIndex: MemoryLayout<Int32>.size)
        
        let line = SCNGeometry(sources: [source], elements: [element])
        return SCNNode(geometry: line)
    }
}
