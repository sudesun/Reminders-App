//
//  MotionManager.swift
//  Reminders App
//

import CoreMotion
import AVFoundation

class MotionManager {
    let motionManager = CMMotionManager()
    var onDeviceMove: (() -> Void)?
    
    func startMotionUpdate() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
        
            if let data = data {
                
                let accelerationMagnitude = sqrt(pow(data.userAcceleration.x, 2) + pow (data.userAcceleration.y, 2) + pow(data.userAcceleration.z, 2))
                let isMoving = accelerationMagnitude > 1.5
                
                if isMoving{
                     
                    self.onDeviceMove?()
                }
            }
        }
    }
    
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
