
import UIKit
import SceneKit
import ARKit

final class ImageDetectionWithModelViewController: UIViewController {
    
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
extension ImageDetectionWithModelViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor,
            let name = imageAnchor.referenceImage.name else {
            return
        }
        
        let sceneName: String
        let sceneNode: String
        if name == "python" {
            sceneName = "snake.scnassets/snake.scn"
            sceneNode = "default"
            
        } else {
            sceneName = "Phone_01.scn"
            sceneNode = "parentNode"
        }
        
        guard let modelScene = SCNScene(named: sceneName),
                let modelNode = modelScene.rootNode.childNode(
                    withName: sceneNode,
                    recursively: true
                ) else {
            return
        }
        
        let rotationAction = SCNAction.rotateBy(
            x: 0,
            y: 0.5,
            z: 0,
            duration: 1
        )
        let inifiniteAction = SCNAction.repeatForever(rotationAction)
        modelNode.runAction(inifiniteAction)
        
        modelNode.position = SCNVector3(
            anchor.transform.columns.3.x,
            anchor.transform.columns.3.y,
            anchor.transform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(modelNode)
    }
}

private extension ImageDetectionWithModelViewController {
    
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
