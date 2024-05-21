import UIKit

final class MainViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let scenes = [
        "Hello World"
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

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        scenes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = scenes[indexPath.row]
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = HelloWorldViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
