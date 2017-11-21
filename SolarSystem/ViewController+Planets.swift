import UIKit
import SceneKit
import ARKit
import CoreMotion
import CoreLocation

 let bodies = [
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

extension ViewController{
    
    func addPlanetsToRootNode(){
        
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
                scene.rootNode.addChildNode(node)
                //                constrainCameraToPlanetNode(node)
                
            }else{
                scene.rootNode.addChildNode(node)
            }
            
            addNorthSouthPoles(node:node)
        }
    }
}
