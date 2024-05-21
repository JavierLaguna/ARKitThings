import UIKit
import SceneKit
import ARKit

final class LoadingModelsViewController: UIViewController {

    @IBOutlet private weak var sceneView: ARSCNView!
    
    private var planes: [OverlayPlane] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDebugOptions()
        sceneView.delegate = self
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

// MARK: ARSCNViewDelegate
extension LoadingModelsViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let plane = OverlayPlane(anchor: planeAnchor)
        planes.append(plane)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let plane = planes.first {
            $0.anchor.identifier == anchor.identifier
        }
        
        plane?.update(anchor: planeAnchor)
    }
}

private extension LoadingModelsViewController {
    
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped(recognizer: UIGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else {
            return
        }
        
        let touchLocation = recognizer.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if let hitResult = hitTestResult.first {
            addBox(hitResult: hitResult)
        }
    }
    
    func addBox(hitResult: ARHitTestResult) {
        let tableScene = SCNScene(named: "bench")
        
        if let tableNode = tableScene?.rootNode.childNode(withName: "SketchUp", recursively: true) {
            
            tableNode.position = SCNVector3(
                hitResult.worldTransform.columns.3.x,
                hitResult.worldTransform.columns.3.y,
                hitResult.worldTransform.columns.3.z
            )
            
            sceneView.scene.rootNode.addChildNode(tableNode)
        }
    }
}
