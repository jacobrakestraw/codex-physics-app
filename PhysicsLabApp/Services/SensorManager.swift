import Foundation
import CoreMotion

/// Wraps the various Core Motion managers and centralises access to device sensors.
final class SensorManager {
    static let shared = SensorManager()

    private let motionManager = CMMotionManager()
    private init() {}

    func startAccelerometerUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.startAccelerometerUpdates()
    }

    func stopAccelerometerUpdates() {
        motionManager.stopAccelerometerUpdates()
    }

    func currentAccelerationMagnitude() -> Double? {
        guard let data = motionManager.accelerometerData else { return nil }
        let x = data.acceleration.x
        let y = data.acceleration.y
        let z = data.acceleration.z
        return sqrt(x * x + y * y + z * z)
    }
}
