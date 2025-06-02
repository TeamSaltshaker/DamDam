import UIKit

final class HomeViewController: UIViewController {
    private let homeView = HomeView()

    override func loadView() {
        view = homeView
    }
}
