
import Foundation
import UIKit
import ARKit
import SceneKit

class GameViewController: UIViewController, ARSCNViewDelegate {
    
    var scnView:ARSCNView!
     let scene = SCNScene()
    let earthRotationNode = SCNNode()
    
    // Camera manipulation
    var camera = SCNCamera()
    let cameraHandle = SCNNode()
    let cameraNode = SCNNode()
    var cameraHandleTransforms:SCNMatrix4?
    var initialOffset:CGPoint = CGPoint(x:0, y:0)
    var lastOffset:CGPoint?
    var lastSpinOffset:CGPoint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
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
        
        let earthNode = SCNNode()
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
        createCamera()
        cameraHandle.constraints = [ SCNLookAtConstraint(target: earthRotationNode) ]
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
        recenterEarthToPositionOfCamera(renderer,scene)
        
    }
    
    
    func createCamera(){
        cameraNode.position = SCNVector3Make(0, 0, 0.01)
        //create a node to manipulate the camera orientation
        cameraHandle.position = SCNVector3Make(0, 0, -0.01)
        let cameraOrientation = SCNNode()
        cameraHandle.addChildNode(cameraOrientation)
        cameraOrientation.addChildNode(cameraNode)
        cameraNode.camera = camera
        cameraNode.camera?.zFar = 800 // ???
        cameraNode.camera?.fieldOfView = 55 // ???
        
        // add an ambient light
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = SKColor(white: 0.3, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        //add a key light to the scene
        let spotLightParentNode = SCNNode()
        spotLightParentNode.position = SCNVector3Make(0, 0, 0)
        let spotLightNode = SCNNode()
        spotLightNode.light = SCNLight()
        spotLightNode.light?.type = .spot
        spotLightNode.light?.color = SKColor(white: 1.0, alpha: 1.0)
        spotLightNode.light?.castsShadow = true
        spotLightNode.light?.shadowColor = SKColor(white: 0.0, alpha: 0.5)
        spotLightNode.light?.zNear = 30
        spotLightNode.light?.zFar = 800
        spotLightNode.light?.shadowRadius = 1.0
        spotLightNode.light?.spotInnerAngle = 15
        spotLightNode.light?.spotOuterAngle = 70
        cameraNode.addChildNode(spotLightParentNode)
        spotLightParentNode.addChildNode(spotLightNode)
        
        
        
        // TODO clarify if it's more accurate to attach cameraHandle to scene or point of view.
        //scene.rootNode.addChildNode(cameraHandle)
        print("👀 - attaching cameraHandle to sceneView.pointOfView ")
        scnView.pointOfView?.addChildNode(cameraHandle)
        
        
    }
    func recenterEarthToPositionOfCamera(_ renderer:SCNSceneRenderer, _ scene: SCNScene){
        // The node provides the position and direction of a virtual camera, and the camera object provides rendering parameters such as field of view and focus.
        guard let pointOfView = renderer.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = orientation + location
        
        
        DispatchQueue.main.async {
             let earthPosition = self.earthRotationNode.position
//                let earthOffset = earthPosition - currentPositionOfCamera
                self.cameraNode.position = earthPosition
                //self.cameraHandle.orientation = orientation
                self.scnView.pointOfView = self.cameraNode
            
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {}
    func sessionWasInterrupted(_ session: ARSession) {}
    func sessionInterruptionEnded(_ session: ARSession) {}
}
