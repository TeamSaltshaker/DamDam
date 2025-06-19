import UIKit

final class AppCoordinator: Coordinator {
    private let diContainer: DIContainer

    let navigationController: UINavigationController
    weak var parent: Coordinator?
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

    func handleSharedURL(_ urlString: String) {
        if let homeCoordinator = childs.compactMap({ $0 as? HomeCoordinator }).first {
            homeCoordinator.showEditClipFromSharedURL(urlString: urlString)
        } else {
            print("HomeCoordinator가 아직 초기화되지 않았습니다.")
        }
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
