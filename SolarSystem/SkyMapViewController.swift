//
//  SkyMapViewController.swift
//  MainProject2
//
//  Created by 王迺瑜 on 2016/10/3.
//  Copyright © 2016年 王迺瑜. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion
import CoreLocation

class SkyMapViewController: UIViewController, CLLocationManagerDelegate  {
    
    var skyMapView = SCNView(frame:.zero)


    
    let scene = SCNScene()
    let boxNode = SCNNode()
    let cameraNode = SCNNode()
    let theText = SCNNode()
    
    let motionManager = CMMotionManager()
    let locationManager = CLLocationManager()
    
    var rotateDegreeCameraX: Double = 0.0
    
   
    
    var heading: Float = 0.0
    

    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        self.view.addSubview(skyMapView)
        skyMapView.frame = self.view.bounds
        skyMapView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        
        //MARK: Create Sky Map sphere
        // create and add a 3D box to the scene
        let skySphere = SCNSphere(radius: 10)
        skySphere.segmentCount = 100
        boxNode.geometry = skySphere
        
        scene.rootNode.addChildNode(boxNode)
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Zero
        scene.rootNode.addChildNode(cameraNode)
        
        //let me know where i'm looking at
        cameraNode.light = SCNLight()
        cameraNode.light?.type = SCNLight.LightType.directional
        cameraNode.light?.color = UIColor(white: 0.75, alpha: 1.0)
        cameraNode.light?.castsShadow = false
        
        //CoreMotionSetting
        motionManager.deviceMotionUpdateInterval = 0.05

        //CoreLocation Heading Setting
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.headingFilter = 3
        
        // create and configure a material
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIImage(named: "constellation_name_last")

        
        // set the material to the 3D object geometry
        if let geometry = boxNode.geometry {
            
        geometry.firstMaterial = material
            
        }
    
        scene.rootNode.addChildNode(theText)
        
        skyMapView.scene = scene
        skyMapView.allowsCameraControl = false
        skyMapView.backgroundColor = UIColor.white
        
        //Set camera orientation
        guard let queue = OperationQueue.current else {return}
        motionManager.startDeviceMotionUpdates(to: queue) { (motion, error) in
            
            guard let motion = motion else {return}
            self.cameraNode.orientation = self.orientationFromCMQuaternion(cmQ: motion.attitude.quaternion, headingQ: self.heading)
        }


        
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // get the data of acclerator
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: OperationQueue.main) { [weak self] (motion, error) in
            if let q = motion?.attitude.quaternion {
                self?.cameraNode.orientation =  SCNQuaternion(q.x, q.y, q.z, -q.w)
            }
        }
        
//        motionManager.stopAccelerometerUpdates()
//
//        guard let queue = OperationQueue.current else {return}
//        motionManager.startDeviceMotionUpdates(to: queue) { (motion, error) in
//            guard let motion = motion else {return}
//
//            self.cameraNode.orientation = self.orientationFromCMQuaternion(cmQ: motion.attitude.quaternion, headingQ: self.heading)
//
//        }
        
        /*if
            let currentUser = user.currentUser,
            let latitude = currentUser.latitude as? Double
        {
        
        boxNode.orientation = self.correctOfSkyMap(self.calculateRevolution(), rotation: self.calculateEarthRotation(), latitude: Float(latitude))
        
        }*/
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        self.motionManager.stopDeviceMotionUpdates()
        
    }
    


    

    //MARK: Correct User and friends' view
    // rotate x-axis (camera node) according to acceleration
    //將最原始起始視角換成春分點//
    private func orientationFromCMQuaternion(cmQ: CMQuaternion, headingQ: Float) -> SCNVector4 {
        let gq1 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(Float(rotateDegreeCameraX) - 90), 1, 0, 0)
        let gq3 = GLKQuaternionMake(Float(cmQ.x), Float(cmQ.y), Float(cmQ.z), Float(cmQ.w))
        let gq2 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 0, 1)
        
        //!!問題：相機node的校正尚有一些問題!!//
        let gq4 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(headingQ), 0, 0, 1)
        let qp = GLKQuaternionMultiply(gq1, gq2)
        let qp2 = GLKQuaternionMultiply(qp, gq4)
        let qp3 = GLKQuaternionMultiply(qp2, gq3)
        let rq = CMQuaternion(x: Double(qp3.x), y: Double(qp3.y), z: Double(qp3.z), w: Double(qp3.w))
        return SCNVector4Make(Float(rq.x), Float(rq.y), Float(rq.z), Float(rq.w))
    }
    
    //!!尚未新增的朋友視線功能!!//
//    //將最原始點視角設定與主角一樣//
//    //但將依據經度的不同去調整看的點//
//    private func orientationFromFriendQuaternion(cmQ: CMQuaternion, headingQ: Float, friendLng: Double) -> SCNVector4 {
//        let gq1 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(Float(rotateDegreeCameraX) - 90), 1, 0, 0)
//        let gq3 = GLKQuaternionMake(Float(cmQ.x), Float(cmQ.y), Float(cmQ.z), Float(cmQ.w))
//        let gq2 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 0, 1)
//        
//        //!!問題：相機node的校正尚有一些問題!!//
//        let gq4 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(headingQ), 0, 0, 1)
//        let gq5 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(Float(longitudeD - friendLng)), 0, 1, 0)
//        let qp = GLKQuaternionMultiply(gq1, gq2)
//        let qp2 = GLKQuaternionMultiply(qp, gq4)
//        let qp3 = GLKQuaternionMultiply(qp2, gq3)
//        let qp4 = GLKQuaternionMultiply(qp3, gq5)
//        let rq = CMQuaternion(x: Double(qp4.x), y: Double(qp4.y), z: Double(qp4.z), w: Double(qp4.w))
//        return SCNVector4Make(Float(rq.x), Float(rq.y), Float(rq.z), Float(rq.w))
//    }

    //MARK: Correct Sky Map
    // get z-axis acceleration data and compute the rotate rate
    func outputAccelerationData(acceleration: CMAcceleration) {
        
        let accZ: Double = fabs(acceleration.z)
        rotateDegreeCameraX = acos(accZ) * 180 / M_PI
        print(rotateDegreeCameraX)
    }

    //校正天球（黃道、赤道座標系統)//
    func correctOfSkyMap(revolution: Float, rotation: Float, latitude: Float) -> SCNVector4 {
        
        //將赤道面與黃道面的傾角23.4397度轉成重疊
        let gq = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(-23.4397), 0, 0, 1)
        //依據日期計算目前離春分點差了幾度（黃道座標系統）
        //! -revolution
        let gq2 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(revolution), 0, 1, 0)
        let qp = GLKQuaternionMultiply(gq, gq2)
        //將赤道面轉回原本的角度
        //! - -> +
        let gq3 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(23.4397), 0, 0, 1)
        let qp2 = GLKQuaternionMultiply(qp, gq3)
        
        //依據自轉角度調整（赤道座標系統）
        //! -rotation
        let gq4 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(rotation), 0, 1, 0)
        let qp3 = GLKQuaternionMultiply(qp2, gq4)
        
        //依據緯度調整對北極星的仰角（緯度）
        //! latitude - 90 -> -latitude
        let gq5 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(latitude - 90), 1, 0, 0)
        let qp4 = GLKQuaternionMultiply(qp3, gq5)
        
        //對比star chart發現圖需右轉90度
        let gq6 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(90), 0, 1, 0)
        let qp5 = GLKQuaternionMultiply(qp4, gq6)
        
        return SCNVector4Make(qp5.x, qp5.y, qp5.z, qp5.w)
        
    }
    
    //計算地球公轉所需調整的角度（黃道座標系統）//
    func calculateRevolution() -> Float {
        
        let degreePerDay: Double = 0.9656112744
        let originalDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as! TimeZone
        let currentDateStr = dateFormatter.string(from: originalDate as Date)
        if let currentDate = dateFormatter.date(from: currentDateStr),
            let vernalEquinox = dateFormatter.date(from: "2016-03-20 04:30") {
            
            let currentDateInSecs = currentDate.timeIntervalSince(vernalEquinox)
            let currentDateInDays = currentDateInSecs / (60 * 60 * 24)
            let rotateDegreesDouble = currentDateInDays * degreePerDay
            let rotateDegrees = Float(rotateDegreesDouble)
            
            return rotateDegrees
            
        } else { return 0.0 }
        
    }
    
    //計算地球自轉所需調整的角度（赤道座標系統）//
    func calculateEarthRotation() -> Float {
        
        let degreePerMinute: Double = 0.25
        let originalDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let originalDateStr = dateFormatter.string(from: originalDate as Date)
        if let currentDate = dateFormatter.date(from: originalDateStr) {
            let calendar = NSCalendar.current
            let hours = Double(calendar.component(.hour, from: currentDate))
            let minutes = Double(calendar.component(.minute, from: currentDate))
            
            print("pass time: \(hours * 60 + minutes)")
            print("Local date: \(originalDate)")
            print("Date in UTC: \(currentDate)")
            
            return Float((hours * 60 + minutes) * degreePerMinute)
            
        } else {return 0.0}
    }
    
    //偵測視角的左右方向
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        if newHeading.headingAccuracy > 0 {
            
        print(newHeading.trueHeading)
        let headingD = newHeading.trueHeading
        self.heading = Float(headingD)
            
        }
        
        locationManager.stopUpdatingHeading()
        
    }

    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        
        return true
    
    }
}
