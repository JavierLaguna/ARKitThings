import Foundation
import SceneKit
import ARKit

final class Missile: SCNNode {
    
    static private let modelName = "missile.scn"
    static private let missileNode = "missileNode"
    static private let effectNode = "effectNode"
    static private let smokeParticles = "smoke.scnp"
    static private let fireParticles = "fire.scnp"
    
    private var scene: SCNScene!
    
    override init() {
        super.init()
        
        scene = SCNScene(named: Self.modelName)!
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        guard let missileNode = scene.rootNode.childNode(withName: Self.missileNode, recursively: true)
        else {
            fatalError("missileNode not found")
        }
        
        addChildNode(missileNode)
        
        if let effectNode = scene.rootNode.childNode(withName: Self.effectNode, recursively: true),
            let smoke = SCNParticleSystem(named: Self.smokeParticles, inDirectory: nil) {
            effectNode.addParticleSystem(smoke)
            addChildNode(effectNode)
        }
    }
    
    func showFireEffect() {
        guard let effectNode = childNode(withName: Self.effectNode, recursively: true) else {
            fatalError("effectNode not found")
        }
        
        effectNode.removeAllParticleSystems()
        
        if let fire = SCNParticleSystem(
            named: Self.fireParticles,
            inDirectory: nil
        ) {
            effectNode.addParticleSystem(fire)
        }
    }
}

