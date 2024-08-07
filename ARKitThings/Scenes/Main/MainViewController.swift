import UIKit

final class MainViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let scenes = Scene.allCases
    
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
        cell.textLabel?.text = scenes[indexPath.row].title
        return cell
    }
}

// MARK: UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = scenes[indexPath.row].viewController
        navigationController?.pushViewController(vc, animated: true)
    }
}
