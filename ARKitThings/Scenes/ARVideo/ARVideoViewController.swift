import UIKit
import SceneKit
import ARKit

final class ARVideoViewController: UIViewController {
    
    @IBOutlet private  weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDebugOptions()
        registerGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
}

private extension ARVideoViewController {
    
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
        
        let videoNode = SKVideoNode(fileNamed: "big_buck_bunny.mp4")
        videoNode.play()
        
        let skScene = SKScene(size: CGSize(
            width: 640,
            height: 480
        ))
        skScene.addChild(videoNode)
        
        videoNode.position = CGPoint(
            x: skScene.size.width / 2,
            y: skScene.size.height / 2
        )
        videoNode.size = skScene.size
        
        let tvPlane = SCNPlane(width: 1.0, height: 0.75)
        tvPlane.firstMaterial?.diffuse.contents = skScene
        tvPlane.firstMaterial?.isDoubleSided = true
        
        let tvPlaneNode = SCNNode(geometry: tvPlane)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0
        
        tvPlaneNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        tvPlaneNode.eulerAngles = SCNVector3(
            Double.pi,
            0,
            0
        )
        
        sceneView.scene.rootNode.addChildNode(tvPlaneNode)
    }
}
