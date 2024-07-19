
import UIKit
import SceneKit
import ARKit

final class ImageDetectionViewController: UIViewController {
    
    @IBOutlet private weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDebugOptions()
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        // Add dynamic images
        /*
         let blackBerryRefImage = ARReferenceImage((UIImage(named: "BlackBerry.JPG")?.cgImage!)!, orientation: CGImagePropertyOrientation.up, physicalWidth: 0.28)
         
         let javaRefImage = ARReferenceImage((UIImage(named: "Java.JPG")?.cgImage!)!, orientation: CGImagePropertyOrientation.up, physicalWidth: 0.16)
         
         configuration.detectionImages = Set([blackBerryRefImage,javaRefImage])
         */
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
}

// MARK: ARSCNViewDelegate
extension ImageDetectionViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor,
              let name = imageAnchor.referenceImage.name else {
            return
        }
        
        DispatchQueue.main.async {
            let textNode = self.createText(text: name)
            textNode.position = SCNVector3(
                node.worldPosition.x,
                node.worldPosition.y,
                node.worldPosition.z
            )
            
            self.sceneView.scene.rootNode.addChildNode(textNode)
        }
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

private extension ImageDetectionViewController {
    
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
