import UIKit

final class AppCoordinator: Coordinator {
    private let diContainer: DIContainer

    let navigationController: UINavigationController
    var parent: Coordinator?
    var childs: [Coordinator] = []

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        configure()
    }

    deinit {
        print("\(Self.self) 메모리 해제")
    }

    func start() {
        showHome()
    }
}

extension AppCoordinator {
    func showHome() {
        let homeCoordinator = HomeCoordinator(
            navigationController: navigationController,
            diContainer: diContainer
        )
        addChild(homeCoordinator)
        homeCoordinator.start()
    }
}

private extension AppCoordinator {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        navigationController.isNavigationBarHidden = true
    }
}
