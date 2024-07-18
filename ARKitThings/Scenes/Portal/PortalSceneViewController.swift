import UIKit
import SceneKit
import ARKit

final class PortalSceneViewController: UIViewController {

    @IBOutlet private weak var sceneView: ARSCNView!
    
    private var planes: [PortalPlane] = []
    
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
extension PortalSceneViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let plane = PortalPlane(anchor: planeAnchor as! ARPlaneAnchor)
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

private extension PortalSceneViewController {
    
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
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if let hitTestResult = hitTestResults.first {
            addPortal(hitResult: hitTestResult)
        }
    }
    
    func addPortal(hitResult: ARHitTestResult) {
        let portalScene = SCNScene(named: "portal.scnassets/portal.scn")!
        let portalNode = (portalScene.rootNode.childNode(withName: "portalNode", recursively: true))!
        
        portalNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(portalNode)
    }
}
