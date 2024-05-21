import ARKit

final class OverlayPlane: SCNNode {
    
    var anchor: ARPlaneAnchor
    var planeGeometry: SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        
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
    }
}
