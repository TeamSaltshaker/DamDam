import UIKit

final class TabBarCoordinator: Coordinator {
    private let diContainer: DIContainer

    let navigationController: UINavigationController
    weak var parent: Coordinator?
    var children: [Coordinator] = []

    private lazy var tabBarController: TabBarViewController = {
        TabBarViewController(coordinator: self)
    }()

    private var currentTab: TabItem = .defaultTab

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

        didSelect(tab: currentTab)
    }
}

extension TabBarCoordinator {
    func didTap(tab: TabItem) {
        guard children.indices.contains(tab.rawValue) else { return }

        if tab != currentTab {
            didSelect(tab: tab)
        } else {
            didReselect(tab: tab)
        }
    }

    func didSelect(tab: TabItem) {
        let targetNav = children[tab.rawValue].navigationController
        tabBarController.switchTo(targetNav)
        tabBarController.updateSelectedTab(tab)
        currentTab = tab
    }

    func didReselect(tab: TabItem) {
        let targetNav = children[tab.rawValue].navigationController

        if targetNav.presentedViewController != nil {
            targetNav.dismiss(animated: false)
        }

        if targetNav.viewControllers.count > 1 {
            targetNav.popToRootViewController(animated: true)
        }
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
