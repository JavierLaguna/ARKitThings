import UIKit
import SceneKit
import ARKit

final class ModelGesturesViewController: UIViewController {
    
    @IBOutlet private weak var sceneView: ARSCNView!
    
    private var newAngleY: Float = 0.0
    private var currentAngleY: Float = 0.0
    private var localTranslatePosition: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDebugOptions()
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        registerGestures()
        
        print("Detecting Plane...")
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
extension ModelGesturesViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            print("Plane Detected")
        }
    }
}

private extension ModelGesturesViewController {
    
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
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned))
        sceneView.addGestureRecognizer(panGestureRecognizer)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector
                                                                      (longPressed))
        sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else {
            return
        }
        
        let touch = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touch, types: .existingPlane)
        
        guard let hitTest = hitTestResults.first,
              let chairScene = SCNScene(named: "chair.dae"),
              let chairNode = chairScene.rootNode.childNode(withName: "parentNode", recursively: true) else {
            return
        }
        
        chairNode.position = SCNVector3(
            hitTest.worldTransform.columns.3.x,
            hitTest.worldTransform.columns.3.y,
            hitTest.worldTransform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(chairNode)
    }
    
    @objc func pinched(recognizer: UIPinchGestureRecognizer) {
        guard recognizer.state == .changed,
              let sceneView = recognizer.view as? ARSCNView else {
            return
        }
        
        let touch = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touch, options: nil)
        
        if let hitTest = hitTestResults.first {
            let chairNode = hitTest.node
            
            let pinchScaleX = Float(recognizer.scale) * chairNode.scale.x
            let pinchScaleY = Float(recognizer.scale) * chairNode.scale.y
            let pinchScaleZ = Float(recognizer.scale) * chairNode.scale.z
            
            chairNode.scale = SCNVector3(
                pinchScaleX,
                pinchScaleY,
                pinchScaleZ
            )
            
            recognizer.scale = 1
        }
    }
    
    @objc func panned(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .changed {
            guard let sceneView = recognizer.view as? ARSCNView else {
                return
            }
            
            let touch = recognizer.location(in: sceneView)
            let translation = recognizer.translation(in: sceneView)
            let hitTestResults = sceneView.hitTest(touch, options: nil)
            
            if let hitTest = hitTestResults.first, let parentNode = hitTest.node.parent {
                newAngleY = Float(translation.x) * (Float) (Double.pi) / 180
                newAngleY += currentAngleY
                parentNode.eulerAngles.y = newAngleY
            }
            
        } else if recognizer.state == .ended {
            currentAngleY = newAngleY
        }
    }
    
    @objc func longPressed(recognizer: UILongPressGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else {
            return
        }
        
        let touch = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touch, options: nil)
        
        guard let hitTest = hitTestResults.first, let parentNode = hitTest.node.parent else {
            return
        }
        
        if recognizer.state == .began {
            localTranslatePosition = touch
            
        } else if recognizer.state == .changed {
            let deltaX = Float(touch.x - localTranslatePosition.x)/700
            let deltaY = Float(touch.y - localTranslatePosition.y)/700
            
            parentNode.localTranslate(by: SCNVector3(
                deltaX,
                0.0,
                deltaY
            ))
            localTranslatePosition = touch
        }
    }
}
