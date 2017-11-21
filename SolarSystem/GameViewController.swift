
import Foundation
import UIKit
import ARKit
import SceneKit


class GameViewController: UIViewController, ARSCNViewDelegate,ARSessionDelegate {
 
    
    var sceneView:ARSCNView!
    let scene = SCNScene()
    let earthRotationNode = SCNNode()
    let earthNode = SCNNode()
    let earthGroupNode = SCNNode()
    let sunNode = SCNNode()
    let sun = SCNSphere(radius: 2.5)
    
    var myLocationNodeOnEarthNode = SCNNode()
    
    
    // Camera
    var camera = SCNCamera()
    let cameraNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARSCNView(frame:.zero)
        self.view.addSubview(sceneView)
        sceneView.frame = self.view.bounds
        sceneView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.black
        sceneView.delegate = self
        
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 0, z: 0)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let baseNode = SCNNode()
        baseNode.position = SCNVector3(0, 0, -15)
        scene.rootNode.addChildNode(baseNode)
        
      
        // sun
        sun.firstMaterial?.diffuse.contents = UIImage(named:"sun.jpg")
        sunNode.geometry = sun
        sunNode.position = SCNVector3(0, 0, 0);
        
        let sunAnimation = CABasicAnimation(keyPath: "contentsTransform")
        sunAnimation.duration = 10
        sunAnimation.fromValue = NSValue.init(caTransform3D:
            CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0),
                                CATransform3DMakeScale(3, 3, 3)))
        sunAnimation.toValue = NSValue.init(caTransform3D:
            CATransform3DConcat(CATransform3DMakeTranslation(1, 1, 0),
                                CATransform3DMakeScale(3, 3, 3)))
        sunAnimation.repeatCount = .infinity
        
        sun.firstMaterial?.diffuse.addAnimation(sunAnimation, forKey: nil)
        sun.firstMaterial?.multiply.addAnimation(sunAnimation, forKey: nil)
        
        baseNode.addChildNode(sunNode)
        
        sun.firstMaterial?.multiply.contents = UIImage(named:"sun.jpg")
        sun.firstMaterial?.multiply.intensity = 0.5;
        sun.firstMaterial?.lightingModel = .constant
        
        sun.firstMaterial?.diffuse.wrapS = .repeat
        sun.firstMaterial?.diffuse.wrapT = .repeat
        sun.firstMaterial?.multiply.wrapS = .repeat
        sun.firstMaterial?.multiply.wrapT = .repeat
        
        
        sunNode.addChildNode(earthRotationNode)
        
        earthGroupNode.position = SCNVector3(15, 0, 0)
        earthRotationNode.addChildNode(earthGroupNode)
        
       
        let earth = SCNSphere(radius: 1.5)
        earth.firstMaterial?.diffuse.contents = UIImage(named: "earth-diffuse-mini.jpg")
        earthNode.geometry = earth
        earthNode.position = SCNVector3(0, 0, 0)
        earthGroupNode.addChildNode(earthNode)
        
        let moonRotationNode = SCNNode()
        earthGroupNode.addChildNode(moonRotationNode)
        
        let moonNode = SCNNode()
        let moon = SCNSphere(radius: 0.75)
        moon.firstMaterial?.diffuse.contents = UIImage(named:"moon.jpg")
        moonNode.geometry = moon
        moonNode.position = SCNVector3Make(5, 0, 0);
        moonRotationNode.addChildNode(moonNode)
        
        let sunHalo = SCNPlane(width: 30, height: 30)
        sunHalo.firstMaterial?.diffuse.contents = UIImage(named: "sun-halo.png")
        sunHalo.firstMaterial?.emission.contents = UIImage(named: "sun-halo.png")
        sunHalo.firstMaterial?.lightingModel = .constant
        sunHalo.firstMaterial?.writesToDepthBuffer = false
        
        let sunHaloNode = SCNNode()
        sunHaloNode.opacity = 0.4;
        sunHaloNode.constraints = [SCNBillboardConstraint()]
        sunHaloNode.geometry = sunHalo
        
        sunNode.addChildNode(sunHaloNode)
        
        earthRotationNode.runAction(
            SCNAction.repeatForever(
                SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0,
                                   duration: 10)
            )
        )
        
        earthNode.runAction(
            SCNAction.repeatForever(
                SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0,
                                   duration: 1)
            )
        )
        
        moonRotationNode.runAction(
            SCNAction.repeatForever(
                SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0,
                                   duration: 1.5)
            )
        )
        
        moonNode.runAction(
            SCNAction.repeatForever(
                SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0,
                                   duration: 1.5)
            )
        )
        
//        attachCameraToTarget(self.myLocationNodeOnEarthNode)
        addMyLocation()

        setupGesture()
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        if let cc = MyCameraCoordinates.getCameraCoordinates(sceneView: sceneView){
//           print("actual iphone camera position:",cc.friendlyString())

//            sceneView.pointOfView?.worldPosition = cameraNode.worldPosition
//            sceneView.pointOfView?.transform = cameraNode.transform

        }

    }
    

    
    
    func attachCameraToTarget(_ targetNode:SCNNode){
        cameraNode.position = SCNVector3Make(0, 0, 30)
        cameraNode.camera = camera
        cameraNode.camera?.zFar = 800 // ???
        cameraNode.camera?.fieldOfView = 55 // ???
        print("👀 - attaching cameraNode to target node ")
        targetNode.addChildNode(cameraNode)
        
    }
    
    func addConstraintsToFakeCameraToFocusOnUserLocation(){

    }
    
    func addMyLocation(){
        
        let stamford = GlobeGlowPoint(lat: 41.0594346, lon: -73.5107157)
        myLocationNodeOnEarthNode = stamford.node
        earthGroupNode.addChildNode(myLocationNodeOnEarthNode)
        
        let distanceConstraint = SCNDistanceConstraint(target: earthGroupNode)
        distanceConstraint.maximumDistance = 10.0
        distanceConstraint.minimumDistance = 9.5
        let lookAtEarthConstraint = SCNLookAtConstraint(target: earthGroupNode)
        lookAtEarthConstraint.isGimbalLockEnabled = true
        let lookAtMyLocationConstraint = SCNLookAtConstraint(target: myLocationNodeOnEarthNode)
        lookAtMyLocationConstraint.isGimbalLockEnabled = true
        sceneView.pointOfView?.constraints = [ lookAtEarthConstraint,lookAtMyLocationConstraint ]
        
    }
    

    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do something with the new transform
        let currentTransform = frame.camera.transform
        print("currentTransform:", currentTransform)
    }
   
    func recenterEarthToCameraCoordinates(_ renderer:SCNSceneRenderer){
//         guard let pointOfView = renderer.pointOfView else { return }
        if let cc = MyCameraCoordinates.getCameraCoordinates(sceneView: sceneView){
            cameraNode.position = SCNVector3(cc.x, cc.y, cc.z - 20)
//            cameraNode.transform = pointOfView.transform
        }
       /* // The node provides the position and direction of a virtual camera, and the camera object provides rendering parameters such as field of view and focus.
       
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = orientation + location
        pointOfView.position
//        cameraNode.position = currentPositionOfCamera*/


    }
    
  
    
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {}
    func sessionWasInterrupted(_ session: ARSession) {}
    func sessionInterruptionEnded(_ session: ARSession) {}
    
    
    func updateState(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
     /*   switch trackingState {
        case .normal
            where frame.anchors.isEmpty:
            state = .normalEmptyAnchors
        case .normal:
            state = .normal(focusContainer.selectedSurface != nil)
        case .notAvailable:
            state = .notAvailable
        case .limited(.excessiveMotion):
            state = .limitedExcessiveMotion
        case .limited(.insufficientFeatures):
            state = .limitedInsufficientFeatures
        case .limited(.initializing):
            state = .limitedInitializing
        }*/
    }
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateState(for: frame, trackingState: frame.camera.trackingState)
    }
    
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateState(for: frame, trackingState: frame.camera.trackingState)
    }
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        guard let frame = session.currentFrame else { return }
        updateState(for: frame, trackingState: camera.trackingState)
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
    
}
extension GameViewController {
    func setupGesture()  {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameViewController.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
    }
    @objc
    func handleTap(gestureRecognize : UITapGestureRecognizer)  {
     
        guard let currentFrame = self.sceneView.session.currentFrame else { return  }

        // INSERT I DON'T KNOW WHAT I'M DOING DOG PICTURE
        // Create a transform with a translation of 0.2 meters in front of the camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        let transform = simd_mul(currentFrame.camera.transform, translation)
        
        // Add a new anchor to the session
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
    }
}
extension ViewController: ARSKViewDelegate{
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode?{
        
        return SKLabelNode(text: "👾")
    }
    func view(_ view: ARSKView, didAdd node: SKNode, for anchor: ARAnchor)
    {
        
    }
    func view(_ view: ARSKView, willUpdate node: SKNode, for anchor: ARAnchor)
    {
        
    }
    func view(_ view: ARSKView, didUpdate node: SKNode, for anchor: ARAnchor)
    {
        
    }
    func view(_ view: ARSKView, didRemove node: SKNode, for anchor: ARAnchor)
    {
        
    }
}
