import UIKit

final class FolderViewController: UIViewController {
    private let viewModel: FolderViewModel

    private let folderView = FolderView()

    init(viewModel: FolderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = folderView
    }
}
