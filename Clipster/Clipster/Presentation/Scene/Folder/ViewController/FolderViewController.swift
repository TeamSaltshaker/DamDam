import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class FolderViewController: UIViewController {
    private let viewModel: FolderViewModel
    private let disposeBag = DisposeBag()

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

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension FolderViewController {
    func configure() {
        setBindings()
    }

    func setBindings() {
        viewModel.state
            .compactMap(\.currentFolderTitle)
            .asDriver(onErrorJustReturn: "")
            .drive { [weak self] currentFolderTitle in
                guard let self else { return }
                title = currentFolderTitle
            }
            .disposed(by: disposeBag)
    }
}
