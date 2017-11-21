
import Foundation
import UIKit
import ARKit
import SceneKit

class GameViewController: UIViewController, ARSCNViewDelegate,ARSessionDelegate {
    
    var scnView:ARSCNView!
     let scene = SCNScene()
    let earthRotationNode = SCNNode()
     let earthNode = SCNNode()
    
    // Camera
    var camera = SCNCamera()
    let cameraNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnView = ARSCNView()
        self.view.addSubview(scnView)
        
        scnView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "V:|[scnView]|", options: NSLayoutFormatOptions(rawValue: 0),
                             metrics: nil, views: ["scnView": scnView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "H:|[scnView]|", options: NSLayoutFormatOptions(rawValue: 0),
                             metrics: nil, views: ["scnView": scnView]))
        
        scnView.scene = scene
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.black
        scnView.delegate = self
        
        
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
        
        let sunNode = SCNNode()
        let sun = SCNSphere(radius: 2.5)
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
        
        let earthGroupNode = SCNNode()
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
        
        let textScn = ARText(text: "moon", font: UIFont.systemFont(ofSize: 10), color:.red, depth: 40)
        
        let textNode = TextNode(distance: 1, scntext: textScn, sceneView: scnView, scale: 1/100.0)
        moonNode.addChildNode(textNode)
        
        

        createCamera()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        scnView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        scnView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
       //recenterEarthToPositionOfCamera(renderer,scene)
    }
    
    
    func createCamera(){
        cameraNode.position = SCNVector3Make(0, 0, 30)
        cameraNode.camera = camera
//        camera.usesOrthographicProjection = true
        cameraNode.camera?.zFar = 800 // ???
        cameraNode.camera?.fieldOfView = 55 // ???
        print("👀 - creating cameraNode constraint to earthNode ")
        cameraNode.constraints = [ SCNLookAtConstraint(target: earthNode) ]
        print("👀 - attaching cameraNode to earth ")
        self.earthNode.addChildNode(cameraNode)
        print("👀 - making the point of view the camera ")
       self.scnView.pointOfView = cameraNode
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do something with the new transform
        let currentTransform = frame.camera.transform
        print("currentTransform:", currentTransform)
    }
    
    func recenterEarthToPositionOfCamera(_ renderer:SCNSceneRenderer, _ scene: SCNScene){
        // The node provides the position and direction of a virtual camera, and the camera object provides rendering parameters such as field of view and focus.
        guard let pointOfView = renderer.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = orientation + location
//        cameraNode.position = currentPositionOfCamera

        
       /* DispatchQueue.main.async {
             let earthPosition = self.earthNode.position
             let earthRotation =  self.earthNode.rotation
             let earthOffset = earthPosition - currentPositionOfCamera
            .position = earthOffset
            self.scnView.pointOfView?.rotation = earthRotation
            
        }*/
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
}
