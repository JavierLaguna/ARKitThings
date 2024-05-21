import UIKit
import SceneKit
import ARKit

final class PlacingVirtualObjectsViewController: UIViewController {

    @IBOutlet private weak var sceneView: ARSCNView!
    
    private let physics: Bool
    private var planes: [OverlayPlane] = []
    
    init(physics: Bool = false) {
        self.physics = physics
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.physics = false
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDebugOptions()
        sceneView.delegate = self
        registerGesture()
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
extension PlacingVirtualObjectsViewController: ARSCNViewDelegate {
    
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

private extension PlacingVirtualObjectsViewController {
    
    func showDebugOptions() {
        #if DEBUG
        sceneView.showsStatistics = true
        sceneView.debugOptions = [
            .showFeaturePoints,
            .showWorldOrigin,
        ]
        #endif
    }
    
    func registerGesture() {
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
        let boxGeometry = SCNBox(
            width: 0.2,
            height: 0.2,
            length: 0.1,
            chamferRadius: physics ? 0.0 : 0.2
        )
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        boxGeometry.materials = [material]
        
        let boxNode = SCNNode(geometry: boxGeometry)
        
        if physics {
            boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            boxNode.position = SCNVector3(
                hitResult.worldTransform.columns.3.x,
                hitResult.worldTransform.columns.3.y + 0.5,
                hitResult.worldTransform.columns.3.z
            )
            
        } else {
            boxNode.position = SCNVector3(
                hitResult.worldTransform.columns.3.x,
                hitResult.worldTransform.columns.3.y + Float(boxGeometry.height / 2),
                hitResult.worldTransform.columns.3.z
            )
        }
        
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
}
