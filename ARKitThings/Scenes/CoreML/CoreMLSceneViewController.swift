import UIKit
import SceneKit
import ARKit
import Vision

final class CoreMLSceneViewController: UIViewController {

    @IBOutlet private weak var sceneView: ARSCNView!
    
    private var resnetModel = Resnet50()
    private var hitTestResult: ARHitTestResult!
    private var visionRequests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDebugOptions()
        sceneView.delegate = self
        registerGestureRecognizers()
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

// MARK: ARSCNViewDelegate
extension CoreMLSceneViewController: ARSCNViewDelegate {
    // Empty
}

private extension CoreMLSceneViewController {
    
    func showDebugOptions() {
        #if DEBUG
        sceneView.showsStatistics = true
//        sceneView.debugOptions = [
//            .showFeaturePoints,
//            .showWorldOrigin,
//        ]
        #endif
    }
    
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer :UIGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        let touchLocation = self.sceneView.center
        let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
        
        guard let hitTestResult = hitTestResults.first else {
            return
        }
        
        self.hitTestResult = hitTestResult
        
        let pixelBuffer = currentFrame.capturedImage
        performVisionRequest(pixelBuffer: pixelBuffer)
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
    
    func performVisionRequest(pixelBuffer :CVPixelBuffer) {
        let visionModel = try! VNCoreMLModel(for: self.resnetModel.model)
        
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            
            guard error == nil,
                  let observations = request.results else {
                return
            }
            
            let observation = observations.first as! VNClassificationObservation
            
            print("Name \(observation.identifier) and confidence is \(observation.confidence)")
            
            DispatchQueue.main.async { [weak self] in
                self?.displayPredictions(text: observation.identifier)
            }
        }
        
        request.imageCropAndScaleOption = .centerCrop
        self.visionRequests = [request]
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .upMirrored, options: [:])
        
        DispatchQueue.global().async { [weak self] in
            guard let visionRequests = self?.visionRequests else { return }
            try! imageRequestHandler.perform(visionRequests)
        }
    }
    
    func displayPredictions(text :String) {
        let node = createText(text: text)
        node.position = SCNVector3(
            hitTestResult.worldTransform.columns.3.x,
            hitTestResult.worldTransform.columns.3.y,
            hitTestResult.worldTransform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(node)
    }
}
