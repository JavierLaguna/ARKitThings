import Foundation
import SceneKit

final class Car: SCNNode {
    
    private var carNode: SCNNode
    private var zVelocityOffset = 0.1
    
    init(node: SCNNode) {
        carNode = node
        
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addChildNode(carNode)
        
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody?.categoryBitMask = BodyType.car.rawValue
    }
    
    func accelerate() {
        let force = simd_make_float4(0, 0, -10.2, 0)
        let rotatedForce = simd_mul(presentation.simdTransform, force)
        let vectorForce = SCNVector3(
            rotatedForce.x,
            rotatedForce.y,
            rotatedForce.z
        )
        physicsBody?.applyForce(vectorForce, asImpulse: false)
    }
    
    func turnRight() {
        physicsBody?.applyTorque(
            SCNVector4(0, 1.0, 0, -1.0),
            asImpulse: false
        )
    }
    
    func turnLeft() {
        physicsBody?.applyTorque(
            SCNVector4(0, 1.0, 0, 1.0),
            asImpulse: false
        )
    }
}

