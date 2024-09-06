
import UIKit

enum Scene: CaseIterable {
    case helloWorld
    case overlayingPlanes
    case enablingVirtualObjects
    case enablingPhysics
    case enablingPhysicsCollisions
    case applyingForces
    case loadingModels
    case missileLaunch
    case colladaModels
    case lightsDefaultLighting
    case lightsSpotLight
    case lightsRoomLightEstimation
    case remoteCar
    case arCoreML
    case occlusion
    case portals
    case arVideo
    case modelGestures
    case imageDetection
    case imageDetectionWithModel
    case imageTraking
    case detect3DObject
    case realisticModel
    case arWatch
    
    var title: String {
        switch self {
        case .helloWorld: "Hello World"
        case .overlayingPlanes: "Overlaying Planes"
        case .enablingVirtualObjects: "Enabling Virtual Objects"
        case .enablingPhysics: "Enabling Physics"
        case .enablingPhysicsCollisions: "Enabling Physics Collisions"
        case .applyingForces: "Applying Forces (Double tap)"
        case .loadingModels: "Loading Models"
        case .missileLaunch: "Missile Launch"
        case .colladaModels: "Collada (DAE) Models"
        case .lightsDefaultLighting: "Lights - DefaultLighting"
        case .lightsSpotLight: "Lights - SpotLight"
        case .lightsRoomLightEstimation: "Lights - Estimated Room Light"
        case .remoteCar: "Remote car"
        case .arCoreML: "AR + CoreML"
        case .occlusion: "Occlusion"
        case .portals: "Portals"
        case .arVideo: "AR Video"
        case .imageDetection: "Image detection"
        case .imageDetectionWithModel: "Image detection with model"
        case .modelGestures: "Model Gestures"
        case .imageTraking: "Image tracking"
        case .detect3DObject: "Detect 3D Object"
        case .realisticModel: "Realistic Model"
        case .arWatch: "AR Watch"
        }
    }
    
    var viewController: UIViewController {
        switch self {
        case .helloWorld: HelloWorldViewController()
        case .overlayingPlanes: OverlayingPlanesViewController()
        case .enablingVirtualObjects: PlacingVirtualObjectsViewController()
        case .enablingPhysics: PlacingVirtualObjectsViewController(physics: true)
        case .enablingPhysicsCollisions: PlacingVirtualObjectsViewController(physics: true, collisions: true)
        case .applyingForces: PlacingVirtualObjectsViewController(physics: true, collisions: true, forces: true)
        case .loadingModels: LoadingModelsViewController()
        case .missileLaunch: MissileLaunchViewController()
        case .colladaModels: ColladaSceneViewController()
        case .lightsDefaultLighting: LightsSceneViewController(mode: .defaultLight)
        case .lightsSpotLight: LightsSceneViewController(mode: .spotLight)
        case .lightsRoomLightEstimation: LightsSceneViewController(mode: .spotLightWithRoomLightEstimation)
        case .remoteCar: RemoteCarViewController()
        case .arCoreML: CoreMLSceneViewController()
        case .occlusion: OcclusionSceneViewController()
        case .portals: PortalSceneViewController()
        case .arVideo: ARVideoViewController()
        case .imageDetection: ImageDetectionViewController()
        case .imageDetectionWithModel: ImageDetectionWithModelViewController()
        case .modelGestures: ModelGesturesViewController()
        case .imageTraking: ImageDetectionWithModelViewController(trakingEnabled: true)
        case .detect3DObject: Detect3DObjectViewController()
        case .realisticModel: RealisticModelViewController()
        case .arWatch: ARWatchViewController()
        }
    }
    
}
