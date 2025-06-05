import UIKit

final class EditClipViewController: UIViewController {
    private let editClipView = EditClipView()

    init(url: URL?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = editClipView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension EditClipViewController {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editClipView.saveButton)
    }
}
