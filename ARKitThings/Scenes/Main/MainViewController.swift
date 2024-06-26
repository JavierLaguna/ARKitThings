import UIKit

final class MainViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let scenes: [(String, UIViewController)] = [
        (
            "Hello World",
            HelloWorldViewController()
        ),
        (
            "Overlaying Planes",
            OverlayingPlanesViewController()
        ),
        (
            "Enabling Virtual Objects",
            PlacingVirtualObjectsViewController()
        ),
        (
            "Enabling Physics",
            PlacingVirtualObjectsViewController(
                physics: true
            )
        ),
        (
            "Enabling Physics Collisions",
            PlacingVirtualObjectsViewController(
                physics: true,
                collisions: true
            )
        ),
        (
            "Applying Forces (Double tap)",
            PlacingVirtualObjectsViewController(
                physics: true,
                collisions: true,
                forces: true
            )
        ),
        (
            "Loading Models",
            LoadingModelsViewController()
        ),
        (
            "Missile Launch",
            MissileLaunchViewController()
        ),
        (
            "Collada (DAE) Models",
            ColladaSceneViewController()
        ),
        (
            "Lights - DefaultLighting",
            LightsSceneViewController(mode: .defaultLight)
        ),
        (
            "Lights - SpotLight",
            LightsSceneViewController(mode: .spotLight)
        ),
        (
            "Lights - Estimated Room Light",
            LightsSceneViewController(mode: .spotLightWithRoomLightEstimation)
        ),
        (
            "Remote car",
            RemoteCarViewController()
        ),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "ARKit Scenes"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        scenes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = scenes[indexPath.row].0
        return cell
    }
}

// MARK: UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = scenes[indexPath.row].1
        navigationController?.pushViewController(vc, animated: true)
    }
}
