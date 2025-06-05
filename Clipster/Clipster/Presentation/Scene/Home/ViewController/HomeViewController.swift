import UIKit

final class HomeViewController: UIViewController {
    private let homeView = HomeView()

    override func loadView() {
        view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func makeAddButtonMenu() -> UIMenu {
        let addFolderAction = UIAction(
            title: "폴더 추가",
            image: UIImage(systemName: "folder")
        ) { _ in
            print("폴더 추가 버튼 탭")
        }

        let addClipAction = UIAction(
            title: "클립 추가",
            image: UIImage(systemName: "paperclip"),
        ) { _ in
            print("클립 추가 버튼 탭")
        }

        return UIMenu(title: "", children: [addFolderAction, addClipAction])
    }
}

private extension HomeViewController {
    func configure() {
        setAttributes()
        setNavigationBarItems()
    }

    func setAttributes() {
        title = "Clipster"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func setNavigationBarItems() {
        let infoButton = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            primaryAction: UIAction { _ in
                print("라이센스 버튼 탭")
            }
        )

        let addButton = UIBarButtonItem(
            systemItem: .add,
            menu: makeAddButtonMenu()
        )

        navigationController?.navigationBar.tintColor = .label
        navigationItem.rightBarButtonItems = [infoButton, addButton]
    }
}
