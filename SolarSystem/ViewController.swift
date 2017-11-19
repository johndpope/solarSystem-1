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



struct Body {
    var name: String!
    var mass: Double!
    var period: Double!
    var rotationPeriod: Double!
    var distance: CGFloat!
    var diameter: CGFloat!
    var moons: [Moon]!
    var ring: Ring?
//    var angle: Do
}

struct Moon {
    var name: String!
    var image: String!
    var period: Double!
    var size: CGFloat!
    var distance: CGFloat!
}

struct Ring {
    var inner: CGFloat!
    var outer: CGFloat!
    var height: CGFloat!
    var image: String!
}

class ViewController: UIViewController, ARSCNViewDelegate {

    var sceneView = ARSCNView(frame:.zero)
    var scene: SCNScene!
    let moMan = CMMotionManager()
    var sunNode = SCNNode()
    var cube:SCNNode?
    var currentGesture: ARGesture?
    
    var bodies = [
        Body(name: "mercury", mass: 0.055, period: 0.24, rotationPeriod: 58.65, distance: 1.0, diameter: 0.382, moons: [], ring: nil),
        Body(name: "venus", mass: 0.815, period: 0.62, rotationPeriod: 243, distance: 1.2, diameter: 0.949, moons: [], ring: nil),
        Body(name: "earth", mass: 1.0, period: 1, rotationPeriod: 1, distance: 1.4, diameter: 10, moons: [
            Moon(name: "moon", image: "art.scnassets/moonTexture.jpg", period: 0.5, size: 0.0025, distance: 0.03)
            ], ring: nil),
        Body(name: "mars", mass: 0.107, period: 1.88, rotationPeriod: 1.03, distance: 2.0, diameter: 0.532, moons: [], ring: nil),
        Body(name: "jupiter", mass: 318, period: 11.86, rotationPeriod: 0.41, distance: 2.4, diameter: 11.209, moons: [], ring: nil),
        Body(name: "saturn", mass: 95, period: 29.46, rotationPeriod: 0.44, distance: 2.8, diameter: 9.44, moons: [], ring: Ring(inner: 0.06, outer: 0.1, height: 0.0001, image: "art.scnassets/saturnRingsTexture.png")),
        Body(name: "uranus", mass: 15, period: 84.01, rotationPeriod: 0.72, distance: 3.2, diameter: 4.007, moons: [], ring: nil),
        Body(name: "neptune", mass: 17, period: 164.8, rotationPeriod: 0.72, distance: 3.6, diameter: 3.883, moons: [], ring: nil)
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(sceneView)
        sceneView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        sceneView.frame = self.view.bounds
        
        scene = SCNScene()
        
        let sunSphere = SCNSphere(radius: 0.3)
       // sunSphere.firstMaterial?.diffuse.contents = UIImage(named:"art.scnassets/sunTexture.jpg")
        
        sunNode.geometry = sunSphere
        sunNode.geometry?.firstMaterial?.fillMode = .lines
        //sunNode.addAnimation(spinAnimation(duration: 40), forKey: "spin")
        sunNode.position = SCNVector3Make(0, -0.2, -2)
        
        let light = SCNLight()
        light.type = .directional
        
        scene.rootNode.addChildNode(sunNode)
        
        for body in bodies {
            
            let sphere = SCNSphere(radius: 0.005 * body.diameter)
            //sphere.firstMaterial?.diffuse.contents = UIImage(named:"art.scnassets/\(body.name!)Texture.jpg")
            sphere.firstMaterial?.fillMode = .lines
        
            let node = SCNNode()
            
            node.name = body.name!
            if (node.name == "earth"){
                addViewCamera(node)
            }
            node.geometry = sphere
            node.rotation = SCNVector4(2,4,0,CGFloat.pi / 4)
            
//            node.pivot = SCNMatrix4Identity
//            node.light = light
            
            node.addAnimation(spinAnimation(duration: 3 * body.rotationPeriod), forKey: "spin")
  
            let rotateAction = SCNAction.rotateAround(center: sunNode.position, radius: 0.5 * body.distance, animationDuration: 10 * body.period)
          
            for moon in body.moons {
                
                let moonSphere = SCNSphere(radius: moon.size)
                moonSphere.firstMaterial?.diffuse.contents = UIImage(named:moon.image)
                let moonNode = SCNNode()
                moonNode.geometry = moonSphere
                moonNode.position = SCNVector3Make(0, 0, 0)
                
                let moonRotateAction = SCNAction.rotateAround(center: SCNVector3(0,0,0), radius: moon.distance, animationDuration: moon.period)
            
                moonNode.runAction(moonRotateAction)
                node.addChildNode(moonNode)
                
            }
            
            node.runAction(rotateAction)
            
            if let ring = body.ring {
                let ringShape = SCNTube(innerRadius: ring.inner, outerRadius: ring.outer, height: ring.height)
                ringShape.firstMaterial?.diffuse.contents = UIImage(named:ring.image)
                
                let ringNode = SCNNode()
                ringNode.geometry = ringShape
                
                node.addChildNode(ringNode)
            }
            
            scene.rootNode.addChildNode(node)
        }
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]

        self.sceneView.debugOptions = [.showConstraints, .showLightExtents, ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.showsStatistics = true
        
        sceneView.delegate = self
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moMan.deviceMotionUpdateInterval = 1.0/60.0
        
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        
//        let frameScene = SCNScene(named: "GyroScene.scn")
//        cube = frameScene?.rootNode.childNode(withName: "cube",  recursively: true)
//        scene.rootNode.addChildNode(cube!)
        moMan.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: OperationQueue.main) { [weak self] (motion, error) in
            if let q = motion?.attitude.quaternion {
                self?.sunNode.orientation = SCNQuaternion(q.x, q.y, q.z, -q.w)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        moMan.stopDeviceMotionUpdates()
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func spinAnimation(duration: Double) -> CABasicAnimation {

        let spin = CABasicAnimation(keyPath: "rotation")
        
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float(2 * CGFloat.pi)))
        spin.duration = duration
        spin.repeatCount = .infinity
        
        return spin
    }
    
    func addViewCamera(_ parentNode:SCNNode) -> Void {
        
        let orbitNode = SCNNode()                           // non-rendering node, holds the camera
        orbitNode.name = "orbit"
        
        let camera = SCNCamera()                            // create a camera
        let cameraRange = 120.0
        camera.xFov = 800.0 / cameraRange
        camera.yFov = 800.0 / cameraRange
        camera.automaticallyAdjustsZRange = true
        
        let cameraNode = SCNNode()
        cameraNode.name = "camra"
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: Float(CGFloat(cameraRange)))
        
        let cameraConstraint = SCNLookAtConstraint(target: parentNode)
        cameraConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [cameraConstraint]
        
        parentNode.addChildNode(cameraNode)                  //            "orbit" << "camra"
        //.addChildNode(orbitNode)                  // "total" << "orbit"
    }
    

    
    // MARK: - ARSCNViewDelegate

/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    
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
}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchEnded)
        guard let touchLocation = touches.first?.location(in: sceneView) else { return }
        let results = sceneView.hitTest(touchLocation, options: [.boundingBoxOnly: true])
        guard let result = results.first else { return }
        currentGesture = ARGesture.startGestureFromTouches(touches, sceneView, result.node)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchMoved)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchEnded)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchCancelled)
    }
}
