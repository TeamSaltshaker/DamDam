import SnapKit
import UIKit

final class EditFolderViewController: UIViewController, UIGestureRecognizerDelegate {
    private let backButton = EditFolderBackButton()
    private let saveButton = EditFolderSaveButton()
    private let editFolderView = EditFolderView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension EditFolderViewController {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        let rightBarButton = UIBarButtonItem(customView: saveButton)
        navigationItem.rightBarButtonItem = rightBarButton
    }

    func setHierarchy() {
        view.addSubview(editFolderView)
    }

    func setConstraints() {
        editFolderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
}
