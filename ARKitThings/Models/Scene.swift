
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
    case imageDetection
    case modelGestures

    var title: String {
        switch self {
        case .helloWorld:
            return "Hello World"
        case .overlayingPlanes:
            return "Overlaying Planes"
        case .enablingVirtualObjects:
            return "Enabling Virtual Objects"
        case .enablingPhysics:
            return "Enabling Physics"
        case .enablingPhysicsCollisions:
            return "Enabling Physics Collisions"
        case .applyingForces:
            return "Applying Forces (Double tap)"
        case .loadingModels:
            return "Loading Models"
        case .missileLaunch:
            return "Missile Launch"
        case .colladaModels:
            return "Collada (DAE) Models"
        case .lightsDefaultLighting:
            return "Lights - DefaultLighting"
        case .lightsSpotLight:
            return "Lights - SpotLight"
        case .lightsRoomLightEstimation:
            return "Lights - Estimated Room Light"
        case .remoteCar:
            return "Remote car"
        case .arCoreML:
            return "AR + CoreML"
        case .occlusion:
            return "Occlusion"
        case .portals:
            return "Portals"
        case .arVideo:
            return "AR Video"
        case .imageDetection:
            return "Image detection"
        case .modelGestures:
            return "Model Gestures"
        }
    }

    var viewController: UIViewController {
        switch self {
        case .helloWorld:
            return HelloWorldViewController()
        case .overlayingPlanes:
            return OverlayingPlanesViewController()
        case .enablingVirtualObjects:
            return PlacingVirtualObjectsViewController()
        case .enablingPhysics:
            return PlacingVirtualObjectsViewController(physics: true)
        case .enablingPhysicsCollisions:
            return PlacingVirtualObjectsViewController(physics: true, collisions: true)
        case .applyingForces:
            return PlacingVirtualObjectsViewController(physics: true, collisions: true, forces: true)
        case .loadingModels:
            return LoadingModelsViewController()
        case .missileLaunch:
            return MissileLaunchViewController()
        case .colladaModels:
            return ColladaSceneViewController()
        case .lightsDefaultLighting:
            return LightsSceneViewController(mode: .defaultLight)
        case .lightsSpotLight:
            return LightsSceneViewController(mode: .spotLight)
        case .lightsRoomLightEstimation:
            return LightsSceneViewController(mode: .spotLightWithRoomLightEstimation)
        case .remoteCar:
            return RemoteCarViewController()
        case .arCoreML:
            return CoreMLSceneViewController()
        case .occlusion:
            return OcclusionSceneViewController()
        case .portals:
            return PortalSceneViewController()
        case .arVideo:
            return ARVideoViewController()
        case .imageDetection:
            return ImageDetectionViewController()
        case .modelGestures:
            return ModelGesturesViewController()
        }
    }
}
