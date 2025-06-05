import SnapKit
import UIKit

final class EditFolderViewController: UIViewController {
    private let editFolderView = EditFolderView()

    override func loadView() {
        view = editFolderView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension EditFolderViewController {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: editFolderView.backButton)

        let rightBarButton = UIBarButtonItem(customView: editFolderView.saveButton)
        navigationItem.rightBarButtonItem = rightBarButton
    }
}
