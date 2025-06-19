import SafariServices
import UIKit

final class HomeCoordinator: Coordinator {
    private let diContainer: DIContainer

    let navigationController: UINavigationController
    var parent: Coordinator?
    var childs: [Coordinator] = []

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        showHome()
    }
}

extension HomeCoordinator {
    func showHome() {
        let reactor = diContainer.makeHomeReactor()
        let vc = HomeViewController(reactor: reactor, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }
}
