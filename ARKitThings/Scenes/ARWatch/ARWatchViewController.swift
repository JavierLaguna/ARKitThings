import UIKit
import SceneKit
import ARKit

final class ARWatchViewController: UIViewController {
    
    @IBOutlet private weak var sceneView: ARSCNView!
    
    private let availableColors: [UIColor] = [.red, .purple, .orange, .blue]
    
    private var offsetX: CGFloat = 20
    private var watchNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        showDebugOptions()
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        
        addColorSwatches()
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
extension ARWatchViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let imageAnchor = anchor as? ARImageAnchor,
              let name = imageAnchor.referenceImage.name,
              name == "watch-identifier" else {
            return
        }
        
        let refImage = imageAnchor.referenceImage
        addWatch(to: node, referenceImage: refImage)
    }
}

private extension ARWatchViewController {
    
    func showDebugOptions() {
#if DEBUG
        sceneView.showsStatistics = true
        sceneView.debugOptions = [
            .showFeaturePoints,
            .showWorldOrigin,
        ]
#endif
    }
    
    func addWatch(to node: SCNNode, referenceImage: ARReferenceImage) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            let watchScene = SCNScene(named: "watch-model.dae")!
            watchNode = watchScene.rootNode.childNode(withName: "watch", recursively: true)!
            
            let cylinder = SCNCylinder(radius: referenceImage.physicalSize.width / 1.8, height: referenceImage.physicalSize.height)
            cylinder.firstMaterial?.diffuse.contents = UIColor.purple
            cylinder.firstMaterial?.colorBufferWriteMask = []
            
            let cylinderNode = SCNNode(geometry: cylinder)
            cylinderNode.eulerAngles.x = .pi / 2
            cylinderNode.renderingOrder = -1
            
            let centerY = (watchNode.boundingBox.max.y + watchNode.boundingBox.min.y) / 2
            
            cylinderNode.position.y = centerY + 0.008
            
            node.addChildNode(watchNode)
            node.addChildNode(cylinderNode)
        }
    }
    
    func addColorSwatches() {
        for availableColor in self.availableColors {
            let swatchView = ColorSwatch(color: availableColor) { color in
                guard let bandNode = self.watchNode.childNode(withName: "band", recursively: true) else {
                    return
                }
                
                bandNode.geometry?.firstMaterial?.diffuse.contents = color
            }
            
            self.view.addSubview(swatchView)
            // configure constraints
            configureConstraints(for: swatchView)
        }
    }
    
    func configureConstraints(for swatchView: UIView) {
        swatchView.translatesAutoresizingMaskIntoConstraints = false
        
        swatchView.widthAnchor.constraint(equalToConstant: swatchView.frame.size.width).isActive = true
        swatchView.heightAnchor.constraint(equalToConstant: swatchView.frame.size.height).isActive = true
        
        swatchView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
        swatchView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: offsetX).isActive = true
        
        offsetX += self.view.frame.width / 4
    }
}
