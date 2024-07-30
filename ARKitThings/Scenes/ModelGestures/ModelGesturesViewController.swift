import UIKit
import SceneKit
import ARKit

final class ModelGesturesViewController: UIViewController, ARSCNViewDelegate {
    
    static private let missileName = "Missile"
    
    @IBOutlet private var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDebugOptions()
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

private extension ModelGesturesViewController {
    
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
        guard let sceneView = recognizer.view as? ARSCNView else {
            return
        }
        
        let touch = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touch, types: .existingPlane)
        
        guard let hitTest = hitTestResults.first,
              let chairScene = SCNScene(named: "chair.dae"),
              let chairNode = chairScene.rootNode.childNode(withName: "parentNode", recursively: true) else {
            return
        }
        
        chairNode.position = SCNVector3(
            hitTest.worldTransform.columns.3.x,
            hitTest.worldTransform.columns.3.y,
            hitTest.worldTransform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(chairNode)
    }
}
