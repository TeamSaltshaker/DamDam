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
        let homeCoordinator = makeHomeCoordinator()
        let searchCoordinator = makeSearchCoordinator()
        let myPageCoordinator = makeMyPageCoordinator()

        addChild(homeCoordinator)
        addChild(searchCoordinator)
        addChild(myPageCoordinator)

        homeCoordinator.start()
        searchCoordinator.showSearch()
        myPageCoordinator.start()

        navigationController.setViewControllers([tabBarController], animated: false)
    }
}

extension TabBarCoordinator {
    func didSelect(tab: TabBarMode) {
        guard children.indices.contains(tab.rawValue) else { return }
        let targetVC = children[tab.rawValue].navigationController
        tabBarController.switchTo(targetVC)
    }
}

private extension TabBarCoordinator {
    func makeHomeCoordinator() -> HomeCoordinator {
        let naviVC = UINavigationController()
        naviVC.isNavigationBarHidden = true

        let coordinator = HomeCoordinator(
            navigationController: naviVC,
            diContainer: diContainer
        )

        return coordinator
    }

    func makeSearchCoordinator() -> HomeCoordinator {
        let naviVC = UINavigationController()
        naviVC.isNavigationBarHidden = true

        let coordinator = HomeCoordinator(
            navigationController: naviVC,
            diContainer: diContainer
        )

        return coordinator
    }

    func makeMyPageCoordinator() -> MyPageCoordinator {
        let naviVC = UINavigationController()
        naviVC.isNavigationBarHidden = true

        let coordinator = MyPageCoordinator(
            navigationController: naviVC,
            diContainer: diContainer
        )

        return coordinator
    }
}
