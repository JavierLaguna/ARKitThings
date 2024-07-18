
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
        if let imageAnchor = anchor as? ARImageAnchor {
            if let name = imageAnchor.referenceImage.name {
                print("name")
//                DispatchQueue.main.async {
//                    
//                    self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//                    self.hud.label.text = name
//                    
//                    self.hud.hide(animated: true, afterDelay: 2.0)
//                }
                
            }
        }
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
