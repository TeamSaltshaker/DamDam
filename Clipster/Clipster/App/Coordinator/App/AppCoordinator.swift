import UIKit

final class AppCoordinator: Coordinator {
    private let diContainer: DIContainer

    let navigationController: UINavigationController
    weak var parent: Coordinator?
    var children: [Coordinator] = []

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    deinit {
        print("\(Self.self) 메모리 해제")
    }

    func start() {
        showTab()
    }
}

extension AppCoordinator {
    func showTab() {
        let tabBarCoordinator = TabBarCoordinator(
            navigationController: navigationController,
            diContainer: diContainer
        )
        addChild(tabBarCoordinator)
        tabBarCoordinator.start()
    }

    func handleSharedURL(_ urlString: String) {
        if let homeCoordinator = children.compactMap({ $0 as? HomeCoordinator }).first {
            homeCoordinator.showEditClipFromSharedURL(urlString: urlString)
        } else {
            print("HomeCoordinator가 아직 초기화되지 않았습니다.")
        }
    }
}
