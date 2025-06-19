import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    var parent: Coordinator? { get set }
    var children: [Coordinator] { get set }

    func start()
    func addChild(_ coordinator: Coordinator)
    func removeChild(_ coordinator: Coordinator)
    func removeAllChild()
}

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        coordinator.parent = self
        children.append(coordinator)
    }

    func removeChild(_ coordinator: Coordinator) {
        children.removeAll { $0 === coordinator }
    }

    func removeAllChild() {
        children.removeAll()
    }
}
