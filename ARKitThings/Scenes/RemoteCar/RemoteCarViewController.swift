import UIKit
import SceneKit
import ARKit

final class RemoteCarViewController: UIViewController {
    
    @IBOutlet private weak var sceneView: ARSCNView!
    @IBOutlet private weak var leftButton: GameButton!
    @IBOutlet private weak var rightButton: GameButton!
    @IBOutlet private weak var upButton: GameButton!
    
    private var planes: [OverlayPlane] = []
    private var car: Car!
    private var carNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDebugOptions()
        sceneView.delegate = self
                
        let carScene = SCNScene(named: "car.dae")
        carNode = carScene?.rootNode.childNode(withName: "car", recursively: true)
        carNode?.scale = SCNVector3(0.3, 0.3, 0.3)
        
        setupControlPad()
        registerGestureRecognizers()
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
extension RemoteCarViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let plane = OverlayPlane(anchor: planeAnchor, collisions: true)
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

private extension RemoteCarViewController {
    
    func showDebugOptions() {
#if DEBUG
        sceneView.showsStatistics = true
        //        sceneView.debugOptions = [
        //            .showFeaturePoints,
        //            .showWorldOrigin,
        //        ]
#endif
    }
    
    func setupControlPad() {
        leftButton.onPress { [weak self] in
            self?.car.turnLeft()
        }
        
        rightButton.onPress { [weak self] in
            self?.car.turnRight()
        }
        
        upButton.onPress { [weak self] in
            self?.car.accelerate()
        }
    }
    
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer :UIGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        guard let hitResult = hitTestResult.first,
            let carNode else {
            return
        }
        
        car = Car(node: carNode)
        car.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y + 0.1, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(car)
    }
}
