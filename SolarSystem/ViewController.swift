import UIKit
import SceneKit
import ARKit
import CoreMotion
import CoreLocation



class ViewController: UIViewController, ARSCNViewDelegate {
    
    lazy var locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    var heading:Float  = 0.0
    
    var geoCentricPOV = SCNNode()
    var camCoords = MyCameraCoordinates()
    var sceneView = ARSCNView(frame:.zero)
    var seasonalTilt = SCNNode()
    var celestialEquatorTilt = SCNNode()
    var scene = SCNScene()
    let moMan = CMMotionManager()
    var sunNode = SCNNode()
    var earth:SCNNode?
    var myLocationNodeOnEarthNode = SCNNode()
    

    // Camera manipulation
    var camera = SCNCamera()
    let cameraHandle = SCNNode()
    let cameraNode = SCNNode()
    var currentGesture: ARGesture? // not used
 
    // Intention here I believe is to be able to provide more degrees of freedom with tilt for the camera within universe eg. to provide street level view
    // reference code - https://github.com/op1000/EarthTravel/tree/master/EarthTravel/Classes
    // |_   cameraHandle
    //   |_   cameraOrientation
    //     |_   cameraNode
    

    func createCamera(position:SCNVector3) {
     
        cameraNode.position = position
         cameraHandle.position = SCNVector3Make(0, 0, -0.01)
        let cameraOrientation = SCNNode()
        cameraHandle.addChildNode(cameraOrientation)
        cameraOrientation.addChildNode(cameraNode)
        cameraNode.camera = camera
        cameraNode.camera?.zFar = 800 // ???
        cameraNode.camera?.fieldOfView = 55 // ???
        print("👀 - sceneView.pointOfView = cameraNode ")
//        sceneView.pointOfView = cameraNode
        
    }

    func addHorizon(){

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
//    func addSunLighting(){
//        // add an ambient light
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = SCNLight()
//        ambientLightNode.light?.type = .directional
//        ambientLightNode.light?.color = SKColor(white: 0.4, alpha: 1.0)
//        sunNode.addChildNode(ambientLightNode)
//        //add a key light to the scene
//        let spotLightParentNode = SCNNode()
//        spotLightParentNode.position = SCNVector3Make(0, 0, 0)
//        let spotLightNode = SCNNode()
//        spotLightNode.light = SCNLight()
//        spotLightNode.light?.type = .spot
//        spotLightNode.light?.color = SKColor(white: 1.0, alpha: 1.0)
//        spotLightNode.light?.castsShadow = true
//        spotLightNode.light?.shadowColor = SKColor(white: 0.0, alpha: 0.5)
//        spotLightNode.light?.zNear = 30
//        spotLightNode.light?.zFar = 800
//        spotLightNode.light?.shadowRadius = 1.0
//        spotLightNode.light?.spotInnerAngle = 15
//        spotLightNode.light?.spotOuterAngle = 70
//        sunNode.addChildNode(spotLightParentNode)
//        spotLightParentNode.addChildNode(spotLightNode)
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buildScene()
        enableLocationManager()
        createCamera(position:SCNVector3(0, 0, 0))
        

        addPlanetsToRootNode(usesGeoCentric:true)
        attachCameraToTargetWithLookAtConstraint(self.earth!)
//        addSunLighting()
        
       
    }
    
    func drawLineFromEarthToSun(){
        let lineBetweenEarthAndSun = cylinderLineBetweenNodeA(nodeA:self.earth!,nodeB:self.sunNode)
        geoCentricPOV.addChildNode(lineBetweenEarthAndSun)
    }
    
    // we attach a camera to earth - not to change the POV - but to simply get the coordinates
    func attachCameraToTargetWithLookAtConstraint(_ targetNode:SCNNode){
        cameraNode.position = SCNVector3Make(0, 0, 30)
        cameraNode.camera = camera
        cameraNode.camera?.zFar = 800 // ???
        cameraNode.camera?.fieldOfView = 55 // ???
        print("👀 - attaching cameraNode to target node ")
        targetNode.addChildNode(cameraNode)
        
        // POV MAGIC - constrain the point of view to focus on the planet earth focusNode.
        let distanceConstraint = SCNDistanceConstraint(target: targetNode)
        distanceConstraint.maximumDistance = 0.3
        distanceConstraint.minimumDistance = 0.1
        let lookAtEarthConstraint = SCNLookAtConstraint(target: targetNode)
        lookAtEarthConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [distanceConstraint, lookAtEarthConstraint ]
        
    }
    
    
    func addMyLocation(){
        
        if let earth = earth{
            let stamford = GlobeGlowPoint(lat: 41.0594346, lon: -73.5107157)
            myLocationNodeOnEarthNode = stamford.node
            earth.addChildNode(myLocationNodeOnEarthNode)
            
            // visually stop the earth spinning by making the point of view focus on this
            let focusNode = SCNNode()
            focusNode.position = SCNVector3Make(0, 0, -0.02)
            earth.addChildNode(focusNode)
            
            // the stamford dot is way above the skies.
            let line = cylinderLineBetweenNodeA(nodeA:myLocationNodeOnEarthNode,nodeB:earth)
            earth.addChildNode(line)
            
            // POV MAGIC - constrain the point of view to focus on the planet earth focusNode.
            let distanceConstraint = SCNDistanceConstraint(target: earth)
            distanceConstraint.maximumDistance = 0.3
            distanceConstraint.minimumDistance = 0.1
            let lookAtEarthConstraint = SCNLookAtConstraint(target: focusNode)
            
//            lookAtEarthConstraint.isGimbalLockEnabled = true
//            sceneView.pointOfView?.constraints = [distanceConstraint, lookAtEarthConstraint ]
        }


        
    }
    
    
    func enableLocationManager(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    func buildScene(){
        
        self.view.addSubview(sceneView)
        sceneView.frame = self.view.bounds
        sceneView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        sceneView.setup()
        // sceneView.showDebug()
        sceneView.delegate = self
        sceneView.scene = scene
        sceneView.scene.background.contents = UIColor.black
        
       /* sceneView.scene.background.contents = [
            "art.scnassets/0mettle.png",
            "art.scnassets/1mettle.png",
            "art.scnassets/2mettle.png",
            "art.scnassets/3mettle.png",
            "art.scnassets/4mettle.png",
            "art.scnassets/5mettle.png",
        ]*/
        
        
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



