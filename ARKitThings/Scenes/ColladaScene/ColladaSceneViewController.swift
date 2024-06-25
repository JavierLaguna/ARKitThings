import UIKit
import SceneKit
import ARKit

final class ColladaSceneViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet private var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.showsStatistics = true
        sceneView.delegate = self
        
        let farmScene = SCNScene(named: "farm.dae")!
        let farmNode = farmScene.rootNode.childNode(withName: "farm", recursively: true)
        
        let scene = SCNScene()
        
        scene.rootNode.addChildNode(farmNode!)
        
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
