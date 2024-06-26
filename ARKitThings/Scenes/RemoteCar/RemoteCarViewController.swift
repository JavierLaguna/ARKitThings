import UIKit
import SceneKit
import ARKit

final class RemoteCarViewController: UIViewController {
    
    @IBOutlet private weak var sceneView: ARSCNView!
    
    private var planes: [OverlayPlane] = []
    private var car: Car!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDebugOptions()
        sceneView.delegate = self
                
        let carScene = SCNScene(named: "car.dae")
        guard let carNode = carScene?.rootNode.childNode(withName: "car", recursively: true) else {
            return
        }
        
        car = Car(node: carNode)
                    
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
        let leftButton = GameButton(frame: CGRect(
            x: 0,
            y: self.sceneView.frame.height - 140,
            width: 50,
            height: 50
        )) { [weak self] in
            self?.car.turnLeft()
        }
        leftButton.setTitle("Left", for: .normal)
        
        let rightButton = GameButton(frame: CGRect(
            x: 60,
            y: self.sceneView.frame.height - 140,
            width: 50,
            height: 50
        )) { [weak self] in
            self?.car.turnRight()
        }
        rightButton.setTitle("Right", for: .normal)
        
        let acceleratorButton = GameButton(frame: CGRect(
            x: 120,
            y: self.sceneView.frame.height - 140,
            width: 60,
            height: 20
        )) { [weak self] in
            self?.car.accelerate()
        }
        acceleratorButton.backgroundColor = UIColor.red
        acceleratorButton.layer.cornerRadius = 10.0
        acceleratorButton.layer.masksToBounds = true
        
        sceneView.addSubview(leftButton)
        sceneView.addSubview(rightButton)
        sceneView.addSubview(acceleratorButton)
    }
    
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer :UIGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        guard let hitResult = hitTestResult.first else {
            return
        }
        
        car.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y + 0.1, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(car)
    }
}
