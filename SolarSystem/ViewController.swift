import UIKit
import SceneKit
import ARKit
import CoreMotion
import CoreLocation



class ViewController: UIViewController, ARSCNViewDelegate {
    
    lazy var locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    var heading:Float  = 0.0
    
    
    var camCoords = MyCameraCoordinates()
    var sceneView = VirtualObjectARView(frame:.zero)
    var seasonalTilt = SCNNode()
    var celestialEquatorTilt = SCNNode()
    var scene = SCNScene()
    let moMan = CMMotionManager()
    var sunNode = SCNNode()
    var earth:SCNNode?
    

    


    // Camera manipulation
    var camera = SCNCamera()
    let cameraHandle = SCNNode()
    let cameraNode = SCNNode()
    var cameraHandleTransforms:SCNMatrix4?
    var initialOffset:CGPoint = CGPoint(x:0, y:0)
    var lastOffset:CGPoint?
    var lastSpinOffset:CGPoint?
    
    var currentGesture: ARGesture? // not used
    
    var myLocationNode:GlobeGlowPoint?
  
    
    var bodies = [
        Body(name: "mercury", mass: 0.055, period: 0.24, rotationPeriod: 58.65, distance: 1.0, diameter: 0.382, moons: [], ring: nil),
        Body(name: "venus", mass: 0.815, period: 0.62, rotationPeriod: 243, distance: 1.2, diameter: 0.949, moons: [], ring: nil),
        Body(name: "earth", mass: 1.0, period: 1, rotationPeriod: 1, distance: 1.4, diameter: 1, moons: [
            Moon(name: "moon", image: "art.scnassets/moonTexture.jpg", period: 0.5, size: 0.0025, distance: 0.03)
            ], ring: nil),
        Body(name: "mars", mass: 0.107, period: 1.88, rotationPeriod: 1.03, distance: 2.0, diameter: 0.532, moons: [], ring: nil),
        Body(name: "jupiter", mass: 318, period: 11.86, rotationPeriod: 0.41, distance: 2.4, diameter: 11.209, moons: [], ring: nil),
        Body(name: "saturn", mass: 95, period: 29.46, rotationPeriod: 0.44, distance: 2.8, diameter: 9.44, moons: [
           /*  Moon(name: "moon1", image: "art.scnassets/moonTexture.jpg", period: 0.45, size: 0.0025, distance: 2.811),
              Moon(name: "moon2", image: "art.scnassets/moonTexture.jpg", period: 0.45, size: 0.0025, distance: 2.821),
              Moon(name: "moon3", image: "art.scnassets/moonTexture.jpg", period: 0.85, size: 0.0025, distance: 2.84),
              Moon(name: "moon4", image: "art.scnassets/moonTexture.jpg", period: 0.665, size: 0.0025, distance: 2.83),
              Moon(name: "moon5", image: "art.scnassets/moonTexture.jpg", period: 0.85, size: 0.0025, distance: 2.82),
              Moon(name: "moon6", image: "art.scnassets/moonTexture.jpg", period: 0.05, size: 0.0025, distance: 2.81)*/
            ], ring: Ring(inner: 0.06, outer: 0.1, height: 0.0001, image: "art.scnassets/saturnRingsTexture.png")),
        Body(name: "uranus", mass: 15, period: 84.01, rotationPeriod: 0.72, distance: 3.2, diameter: 4.007, moons: [], ring: nil),
        Body(name: "neptune", mass: 17, period: 164.8, rotationPeriod: 0.72, distance: 3.6, diameter: 3.883, moons: [], ring: nil)
    ]
    

    // Intention here I believe is to be able to provide more degrees of freedom with tilt for the camera within universe eg. to provide street level view
    // reference code - https://github.com/op1000/EarthTravel/tree/master/EarthTravel/Classes
    func createEnvironment() {
        // |_   cameraHandle
        //   |_   cameraOrientation
        //     |_   cameraNode
        
        
        //create a main camera
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
        sceneView.pointOfView?.addChildNode(cameraHandle)



        //  horizon
        if false{
            let floor = SCNFloor()
            floor.reflectionFalloffEnd = 0
            floor.reflectivity = 0
            let floorNode = SCNNode()
            floorNode.geometry = floor
            //floorNode.geometry.firstMaterial?.diffuse.contents = "wood.png"
            floorNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
            floorNode.geometry?.firstMaterial?.diffuse.wrapS = .repeat
            floorNode.geometry?.firstMaterial?.diffuse.wrapT = .repeat
            floorNode.geometry?.firstMaterial?.diffuse.mipFilter = .nearest
            floorNode.geometry?.firstMaterial?.isDoubleSided = false
            floorNode.physicsBody = SCNPhysicsBody.static()
            floorNode.physicsBody?.restitution = 1.0
            scene.rootNode.addChildNode(floorNode)
        }
       
        // Sun
        let sunSphere = SCNSphere(radius: 0.1)
        sunNode.geometry = sunSphere
        sunSphere.firstMaterial?.diffuse.contents = UIImage(named:"art.scnassets/sunTexture.jpg")
        sunNode.addAnimation(spinAnimation(duration: 40), forKey: "spin")
        sunNode.position = SCNVector3Make(0, 0, -2)
        addNorthSouthPoles(node:sunNode)
        scene.rootNode.addChildNode(sunNode)
        
        
        for body in bodies {
            
            let sphere = SCNSphere(radius: 0.005 * body.diameter)
            //  sphere.segmentCount = 30
            sphere.firstMaterial?.diffuse.contents = UIImage(named:"art.scnassets/\(body.name!)Texture.jpg")
            
            // sphere.firstMaterial?.fillMode = .lines
            
            let node = SCNNode()
            //node.opacity = 0.6
            node.geometry?.firstMaterial?.transparencyMode = .rgbZero
            node.geometry?.firstMaterial?.transparency = 1.0
            node.name = body.name!
            node.geometry = sphere
            node.rotation = SCNVector4(2,4,0,CGFloat.pi / 4)
            if (node.name != "earth"){
                node.addAnimation(spinAnimation(duration: 3 * body.rotationPeriod), forKey: "spin")
                
            }
            
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
            
            if (node.name == "earth"){
                
                earth = node
                
                //                seasonalTilt.addChildNode()
                //
                //                // tilt it on it's axis (23.5 degrees), varied by the actual day of the year
                //                // (note that children nodes are correctly tilted with the parents coordinate space)
                //                let calendar = Calendar(identifier: .gregorian)
                //                let dayOfYear = Double( calendar.ordinality(of: .day, in: .year, for: Date())! )
                //                let daysSinceWinterSolstice = remainder(dayOfYear + 10.0, kDaysInAYear)
                //                let daysSinceWinterSolsticeInRadians = daysSinceWinterSolstice * 2.0 * Double.pi / kDaysInAYear
                //                let tiltXRadians = -cos( daysSinceWinterSolsticeInRadians) * kTiltOfEarthsAxisInRadians
                //                //
                //                seasonalTilt.eulerAngles = SCNVector3(x: Float(tiltXRadians), y: 0.0, z: 0)
                scene.rootNode.addChildNode(node)
                constrainCameraToPlanetNode(node)

            }else{
                scene.rootNode.addChildNode(node)
            }
            
            addNorthSouthPoles(node:node)
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(sceneView)
        sceneView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        sceneView.frame = self.view.bounds
        sceneView.setup()
//        sceneView.showDebug()
        sceneView.delegate = self
        sceneView.scene = scene
        
        createEnvironment()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moMan.deviceMotionUpdateInterval = 1.0/60.0
    
        listenForCoreMotionChanges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        moMan.stopDeviceMotionUpdates()
        
        // Pause the view's session
        sceneView.session.pause()
    }
    

    
}



