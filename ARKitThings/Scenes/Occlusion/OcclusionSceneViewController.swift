import UIKit
import SceneKit
import ARKit

final class OcclusionSceneViewController: UIViewController {

    @IBOutlet private weak var sceneView: ARSCNView!
    
    private var planes: [OcclusionPlane] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDebugOptions()
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
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
extension OcclusionSceneViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let plane = OcclusionPlane(anchor: planeAnchor as! ARPlaneAnchor)
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

private extension OcclusionSceneViewController {
    
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
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.8
        
        let fishScene = SCNScene(named: "fish.dae")!
        let fishNode = fishScene.rootNode.childNode(withName: "fish", recursively: true)!
        fishNode.simdTransform =  matrix_multiply(currentFrame.camera.transform, translation)
        fishNode.scale = SCNVector3(0.25, 0.25, 0.25)
        
        sceneView.scene.rootNode.addChildNode(fishNode)
    }
}
