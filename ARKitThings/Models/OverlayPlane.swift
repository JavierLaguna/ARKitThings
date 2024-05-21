import ARKit

final class OverlayPlane: SCNNode {
    
    private(set) var anchor: ARPlaneAnchor
    private let collisions: Bool
    var planeGeometry: SCNPlane!
    
    init(anchor: ARPlaneAnchor, collisions: Bool = false) {
        self.anchor = anchor
        self.collisions = collisions
        
        super.init()
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        planeGeometry = SCNPlane(
            width: CGFloat(anchor.planeExtent.width),
            height: CGFloat(anchor.planeExtent.height)
        )
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "overlay_grid.png")
        
        planeGeometry.materials = [material]
        
        let planeNode = SCNNode(geometry: planeGeometry)
        
        if collisions {
            planeNode.physicsBody = SCNPhysicsBody(
                type: .static,
                shape: SCNPhysicsShape(
                    geometry: planeGeometry,
                    options: nil
                )
            )
            planeNode.physicsBody?.categoryBitMask = BodyType.plane.rawValue
        }
        
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
    
    func update(anchor: ARPlaneAnchor) {
        planeGeometry.width = CGFloat(anchor.planeExtent.width)
        planeGeometry.height = CGFloat(anchor.planeExtent.height)
        position = SCNVector3Make(
            anchor.center.x,
            0,
            anchor.center.z
        )
        
        if collisions, let planeNode = childNodes.first {
            
            planeNode.physicsBody = SCNPhysicsBody(
                type: .static,
                shape: SCNPhysicsShape(
                    geometry: planeGeometry,
                    options: nil
                )
            )
            
        }
    }
}
