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
