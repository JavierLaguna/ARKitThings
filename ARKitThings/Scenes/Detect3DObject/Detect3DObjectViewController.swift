
import UIKit
import SceneKit
import ARKit

/**
- Docs
https://developer.apple.com/documentation/arkit/arkit_in_ios/content_anchors/scanning_and_detecting_3d_objects
 */

final class Detect3DObjectViewController: UIViewController {
    
    @IBOutlet private weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDebugOptions()
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let referenceImages = ARReferenceObject.referenceObjects(inGroupNamed: "AR 3D Models", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionObjects = referenceImages
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
}

// MARK: ARSCNViewDelegate
extension Detect3DObjectViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let objectAnchor = anchor as? ARObjectAnchor,
              let name = objectAnchor.referenceObject.name else {
            return
        }
        
        let text = SCNText(string: name, extrusionDepth: 0.0)
        text.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(
            0.002,
            0.002,
            0.002
        )
        node.addChildNode(textNode)
    }
    
    func createText(text: String) -> SCNNode {
        let parentNode = SCNNode()
        
        let sphere = SCNSphere(radius: 0.01)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor.orange
        sphere.firstMaterial = sphereMaterial
        let sphereNode = SCNNode(geometry: sphere)
        
        let textGeometry = SCNText(string: text, extrusionDepth: 0)
        textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        textGeometry.firstMaterial?.diffuse.contents = UIColor.orange
        textGeometry.firstMaterial?.specular.contents = UIColor.white
        textGeometry.firstMaterial?.isDoubleSided = true
        
        let font = UIFont(name: "Futura", size: 0.15)
        textGeometry.font = font
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        
        parentNode.addChildNode(sphereNode)
        parentNode.addChildNode(textNode)
        return parentNode
    }
}

private extension Detect3DObjectViewController {
    
    func showDebugOptions() {
#if DEBUG
        sceneView.showsStatistics = true
        sceneView.debugOptions = [
            .showFeaturePoints,
            .showWorldOrigin,
        ]
#endif
    }
}
