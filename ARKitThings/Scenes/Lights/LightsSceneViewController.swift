import UIKit
import SceneKit
import ARKit

final class LightsSceneViewController: UIViewController {

    @IBOutlet private weak var sceneView: ARSCNView!
    
    private let mode: Mode
    private var planes: [OverlayPlane] = []
    
    init(mode: Mode) {
        self.mode = mode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        mode = .defaultLight
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDebugOptions()
        sceneView.delegate = self
        registerGestures()
        setupPlaneToggleSwitch()
        
        sceneView.autoenablesDefaultLighting = mode == .defaultLight
        
        if mode == .spotLight || mode == .spotLightWithRoomLightEstimation {
            insertSpotLight(position: SCNVector3(0, 1.0, 0))
        }
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
extension LightsSceneViewController: ARSCNViewDelegate {
    
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
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard mode == .spotLightWithRoomLightEstimation,
              let lightEstimate = sceneView.session.currentFrame?.lightEstimate else {
            return
        }
        
        let spotNode = sceneView.scene.rootNode.childNode(withName: "SpotNode", recursively: true)
        spotNode?.light?.intensity = lightEstimate.ambientIntensity
        
        print(spotNode?.light?.intensity)
    }
}

private extension LightsSceneViewController {
    
    func showDebugOptions() {
        #if DEBUG
        sceneView.showsStatistics = true
        sceneView.debugOptions = [
            .showFeaturePoints,
            .showWorldOrigin,
        ]
        #endif
    }
    
    func insertSpotLight(position: SCNVector3) {
        let spotLight = SCNLight()
        spotLight.type = .spot
        spotLight.spotInnerAngle = 45
        spotLight.spotOuterAngle = 45
        
        let spotNode = SCNNode()
        spotNode.name = "SpotNode"
        spotNode.light = spotLight
        spotNode.position = position
        
        spotNode.eulerAngles = SCNVector3(
            -Double.pi / 2.0,
             0,
             -0.2
        )
        sceneView.scene.rootNode.addChildNode(spotNode)
    }
    
    func setupPlaneToggleSwitch() {
        let planeToggleSwitch = UISwitch(frame: CGRect(
            x: 10,
            y: sceneView.frame.height - 140,
            width: 100,
            height: 33
        ))
        planeToggleSwitch.addTarget(self, action: #selector(planeSwitchToggled), for: .valueChanged)
        sceneView.addSubview(planeToggleSwitch)
    }
    
    @objc func planeSwitchToggled(planeSwitch :UISwitch) {
        let configuration = sceneView.session.configuration as! ARWorldTrackingConfiguration
        
        configuration.planeDetection = []
        sceneView.session.run(configuration, options: [])
        
        for plane in planes {
            plane.planeGeometry.materials.forEach { material in
                material.diffuse.contents = UIColor.clear
            }
        }
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
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if let hitResult = hitTestResult.first {
            addBox(hitResult: hitResult)
        }
    }
    
    @objc func doubleTapped(recognizer: UIGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else {
            return
        }
        
        let touchLocation = recognizer.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, options: [:])
        
        if let hitResult = hitTestResult.first {
            let node = hitResult.node
            node.physicsBody?.applyForce(
                SCNVector3(
                    hitResult.worldCoordinates.x * 2.0,
                    2.0,
                    hitResult.worldCoordinates.z * 2.0
                ),
                asImpulse: true
            )
        }
    }
    
    func addBox(hitResult: ARHitTestResult) {
        let boxGeometry = SCNBox(
            width: 0.2,
            height: 0.2,
            length: 0.1,
            chamferRadius: 0.0
        )
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        boxGeometry.materials = [material]
        
        let boxNode = SCNNode(geometry: boxGeometry)
        
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        boxNode.physicsBody?.categoryBitMask = BodyType.box.rawValue
        
        boxNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y + 0.5,
            hitResult.worldTransform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
}

extension LightsSceneViewController {
    
    enum Mode {
        case defaultLight
        case spotLight
        case spotLightWithRoomLightEstimation
    }
}
