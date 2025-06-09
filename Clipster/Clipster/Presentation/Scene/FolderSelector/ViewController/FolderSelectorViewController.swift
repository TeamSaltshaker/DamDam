import UIKit

final class FolderSelectorViewController: UIViewController {
    private let folderSelectorView = FolderSelectorView()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = folderSelectorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
