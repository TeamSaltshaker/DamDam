import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    var parent: Coordinator? { get set }
    var childs: [Coordinator] { get set }

    func start()
    func addChild(_ coordinator: Coordinator)
    func removeChild(_ coordinator: Coordinator)
    func removeAllChild()
}

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        coordinator.parent = self
        childs.append(coordinator)
    }

    func removeChild(_ coordinator: Coordinator) {
        childs.removeAll { $0 === coordinator }
    }

    func removeAllChild() {
        childs.removeAll()
    }
}
