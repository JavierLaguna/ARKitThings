import UIKit
import SceneKit
import ARKit

final class MissileLaunchViewController: UIViewController, ARSCNViewDelegate {
    
    static private let missileName = "Missile"
    
    @IBOutlet private var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        showDebugOptions()
        sceneView.delegate = self
        
        let missile = Missile()
        missile.name = Self.missileName
        missile.position = SCNVector3(0, 0, -4)
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(missile)
        sceneView.scene = scene
        
        registerGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
}

private extension MissileLaunchViewController {
    
    func showDebugOptions() {
        #if DEBUG
        sceneView.showsStatistics = true
        sceneView.debugOptions = [
            .showFeaturePoints,
            .showWorldOrigin,
        ]
        #endif
    }
    
    func registerGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer :UITapGestureRecognizer) {
        guard let missileNode = sceneView.scene.rootNode.childNode(withName: Self.missileName, recursively: true)
            else {
                fatalError("Missile not found")
        }
        
        (missileNode as? Missile)?.showFireEffect()
        missileNode.physicsBody = SCNPhysicsBody(
            type: .dynamic,
            shape: nil
        )
        missileNode.physicsBody?.isAffectedByGravity = false
        missileNode.physicsBody?.damping = 0.0
        missileNode.physicsBody?.applyForce(
            SCNVector3(0, 100, 0),
            asImpulse: false
        )
    }
}
