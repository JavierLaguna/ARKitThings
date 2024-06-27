import Foundation
import SceneKit
import ARKit

final class OcclusionPlane: SCNNode {
    
    var anchor: ARPlaneAnchor
    var planeGeometry: SCNPlane!
    
    init(anchor :ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(anchor :ARPlaneAnchor) {
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)
        position = SCNVector3Make(
            anchor.center.x,
            0,
            anchor.center.z
        )
        
        let planeNode = childNodes.first!
        
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        
    }
    
    private func setup() {
        planeGeometry = SCNPlane(
            width: CGFloat(anchor.extent.x),
            height: CGFloat(anchor.extent.z)
        )
        
        let material = SCNMaterial()
        
        self.planeGeometry.materials = [material]
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(
                geometry: planeGeometry,
                options: nil
            )
        )
     
        planeGeometry.firstMaterial?.colorBufferWriteMask = []
        planeNode.renderingOrder = -1
        
        planeNode.position = SCNVector3Make(
            anchor.center.x,
            0,
            anchor.center.z
        )
        planeNode.transform = SCNMatrix4MakeRotation(
            Float(-Double.pi / 2.0),
            1.0,
            0.0,
            0.0
        )
        
        addChildNode(planeNode)
    }
}
