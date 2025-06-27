import UIKit

final class TabBarCoordinator: Coordinator {
    private let diContainer: DIContainer

    let navigationController: UINavigationController
    weak var parent: Coordinator?
    var children: [Coordinator] = []

    private lazy var tabBarController: TabBarViewController = {
        TabBarViewController(coordinator: self)
    }()

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let homeNavi = UINavigationController()
        homeNavi.isNavigationBarHidden = true

        let homeCoordinator = HomeCoordinator(
            navigationController: homeNavi,
            diContainer: diContainer
        )
        addChild(homeCoordinator)
        homeCoordinator.start()

        navigationController.setViewControllers([tabBarController], animated: false)
    }
}

extension TabBarCoordinator {
    func didSelect(tab: TabBarMode) {
        switch tab {
        case .home:
            tabBarController.switchTo(children[tab.rawValue].navigationController)
        case .myPage:
            tabBarController.switchTo(UIViewController())
        }
    }

    func didTapAddClip() {
        print("Tap Add Clip")
    }

    func didTapAddFolder() {
        print("Tap Add Folder")
    }
}
