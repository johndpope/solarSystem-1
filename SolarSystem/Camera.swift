//
//  Camera.swift
//  SolarSystem
//
//  Created by John Pope on 11/20/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import Foundation
/*
 func privateTiltCamera(withOffset offset: CGPoint) -> Bool {
 var offset = offset
 offset.x += initialOffset.x
 offset.y += initialOffset.y
 var tr: CGPoint
 tr.x = offset.x - lastOffset!.x
 tr.y = offset.y - lastOffset!.y
 lastOffset = offset
 offset.x *= 0.1
 offset.y *= 0.1
 var rx: Float = offset.y
 //offset.y > 0 ? log(1 + offset.y * offset.y) : -log(1 + offset.y * offset.y);
 var ry: Float = offset.x
 //offset.x > 0 ? log(1 + offset.x * offset.x) : -log(1 + offset.x * offset.x);
 ry *= 0.05
 rx *= 0.05
 rx = -rx
 //on iOS, invert rotation on the X axis
 if rx > 0.5 {
 rx = 0.5
 initialOffset.y -= tr.y
 lastOffset.y -= tr.y
 }
 if rx < -M_PI_2 {
 rx = -M_PI_2
 initialOffset.y -= tr.y
 lastOffset.y -= tr.y
 }
 if ry > MAX_RY {
 ry = MAX_RY
 initialOffset.x -= tr.x
 lastOffset.x -= tr.x
 }
 if ry < -MAX_RY {
 ry = -MAX_RY
 initialOffset.x -= tr.x
 lastOffset.x -= tr.x
 }
 ry = -ry
 cameraHandle.eulerAngles = SCNVector3Make(rx, ry, 0)
 return true
 }
 */
