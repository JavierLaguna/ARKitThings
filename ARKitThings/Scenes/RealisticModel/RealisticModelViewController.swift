import UIKit
import SceneKit
import ARKit

final class RealisticModelViewController: UIViewController {

    @IBOutlet private weak var sceneView: ARSCNView!
    
    private var planes: [OverlayPlane] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDebugOptions()
        sceneView.delegate = self
        registerGestures()
        addLight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
}

// MARK: ARSCNViewDelegate
extension RealisticModelViewController: ARSCNViewDelegate {
    
}

private extension RealisticModelViewController {
    
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
        guard let sceneView = recognizer.view as? ARSCNView else {
            return
        }
        
        let touchLocation = recognizer.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlane)
        
        if let hitResult = hitTestResult.first {
            let position = SCNVector3(
                hitResult.worldTransform.columns.3.x,
                hitResult.worldTransform.columns.3.y,
                hitResult.worldTransform.columns.3.z
            )
            
            addCake(at: position)
        }
    }
    
    func addCake(at position: SCNVector3) {
        let cakeScene = SCNScene(named: "art.scnassets/cake-assets/cake-model.dae")!
        let baseNode = cakeScene.rootNode.childNode(withName: "baseNode", recursively: true)!
        let cakeNode = baseNode.childNode(withName: "cake", recursively: true)!
        let plateNode = baseNode.childNode(withName: "plate", recursively: true)!
        
        cakeNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
        cakeNode.geometry?.firstMaterial?.normal.contents = UIImage(named: "art.scnassets/cake-assets/CL_LR_01NormalsMap.jpg")
        cakeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/cake-assets/CL_LR_01DiffuseMap.jpg")
        
        plateNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
        plateNode.geometry?.firstMaterial?.metalness.contents = 0.8
        plateNode.geometry?.firstMaterial?.roughness.contents = 0.2
        
        baseNode.position = position
        
        addPlaneTo(baseNode)
        
        sceneView.scene.rootNode.addChildNode(baseNode)
    }
    
    func addPlaneTo(_ node: SCNNode) {
        let plane = SCNPlane(width: 200, height: 200)
        plane.firstMaterial = SCNMaterial()
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.colorBufferWriteMask = .init(rawValue: 0)
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = .pi / 2
        node.addChildNode(planeNode)
    }
    
    func addLight() {
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 0
        directionalLight.castsShadow = true
        directionalLight.shadowMode = .deferred
        directionalLight.shadowColor = UIColor(
            displayP3Red: 0,
            green: 0,
            blue: 0,
            alpha: 0.5
        )
        directionalLight.shadowSampleCount = 10
        
        let directionalLightNode = SCNNode()
        directionalLightNode.light = directionalLight
        directionalLightNode.rotation = SCNVector4Make(
            1,
            0,
            0,
            -Float.pi / 2
        )
        
        sceneView.scene.rootNode.addChildNode(directionalLightNode)
    }
    
}
