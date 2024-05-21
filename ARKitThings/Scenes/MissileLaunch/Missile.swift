import Foundation
import SceneKit
import ARKit

final class Missile: SCNNode {
    
    private var scene: SCNScene!
    
    override init() {
        super.init()
        
        scene = SCNScene(named: "missile.scn")!
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        guard let missileNode = scene.rootNode.childNode(withName: "missileNode", recursively: true),
            let smokeNode = scene.rootNode.childNode(withName: "smokeNode", recursively: true)
            else {
                fatalError("Node not found!")
        }
        
        addChildNode(missileNode)
        
        if let smoke = SCNParticleSystem(
            named: "smoke.scnp",
            inDirectory: nil
        ) {
            smokeNode.addParticleSystem(smoke)
            addChildNode(smokeNode)
        }
    }
}

