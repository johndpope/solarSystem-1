//
//  ARText.swift
//  ARKeyboard
//
//  Created by Mark Zhong on 7/20/17.
//  Copyright © 2017 Mark Zhong. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ARText:SCNText{
    
    
    override init() {
        super.init()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    init(text:String,
        font:UIFont,
        color:UIColor,
        depth:CGFloat
        ){
        super.init()
        
        self.string = text
        self.extrusionDepth = depth
        self.font = font
        self.alignmentMode = kCAAlignmentCenter
        self.truncationMode = kCATruncationMiddle
        self.firstMaterial?.isDoubleSided = true
        self.firstMaterial!.diffuse.contents = color        
        self.flatness = 0.3
    
    }
    
}


class TextNode: SCNNode {
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(distance:Float, scntext:SCNText, sceneView:ARSCNView, scale:CGFloat){
        super.init()
        
        
        guard let pointOfView = sceneView.pointOfView else { return }
        
        let mat = pointOfView.transform
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        let currentPosition = pointOfView.position + (dir * distance)
        
        
        self.geometry = scntext
        self.position = currentPosition
        self.simdRotation = pointOfView.simdRotation
        self.setPivot()
        self.scale = SCNVector3(scale, scale, scale)
        
    }
    
    
}

class CylinderLine: SCNNode {
    init( parent: SCNNode, v1: SCNVector3, v2: SCNVector3, radius: CGFloat, radSegmentCount: Int, color: UIColor)
    {
        super.init()
        
        let  height = v1.distance(receiver: v2)
        position = v1
        let nodeV2 = SCNNode()
        nodeV2.position = v2
        parent.addChildNode(nodeV2)
        
        let zAlign = SCNNode()
        zAlign.eulerAngles.x = Float(CGFloat.pi / 2)
        
        let cyl = SCNCylinder(radius: radius, height: CGFloat(height))
        cyl.radialSegmentCount = radSegmentCount
        cyl.firstMaterial?.diffuse.contents = color
        
        let nodeCyl = SCNNode(geometry: cyl )
        nodeCyl.position.y = -height/2
        zAlign.addChildNode(nodeCyl)
        
        addChildNode(zAlign)
        
        constraints = [SCNLookAtConstraint(target: nodeV2)]
    }
    
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

private extension SCNVector3{
    func distance(receiver:SCNVector3) -> Float{
        let xd = receiver.x - self.x
        let yd = receiver.y - self.y
        let zd = receiver.z - self.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))
        
        if (distance < 0){
            return (distance * -1)
        } else {
            return (distance)
        }
    }
}
