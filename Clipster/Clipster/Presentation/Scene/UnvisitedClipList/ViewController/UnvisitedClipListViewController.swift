import RxCocoa
import RxSwift
import UIKit

final class UnvisitedClipListViewController: UIViewController {
    private let disposeBag = DisposeBag()

    private let unvisitedClipListViewModel: UnvisitedClipListViewModel
    private let unvisitedClipListView = UnvisitedClipListView()

    init(unvisitedClipListViewModel: UnvisitedClipListViewModel) {
        self.unvisitedClipListViewModel = unvisitedClipListViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        unvisitedClipListViewModel.action.accept(.viewDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unvisitedClipListViewModel.action.accept(.viewWillAppear)
    }

    override func loadView() {
        view = unvisitedClipListView
    }
}

private extension UnvisitedClipListViewController {
    func configure() {
        setAttributes()
        setBindings()
    }

    func setAttributes() {
        title = "방문하지 않은 클립"
    }

    func setBindings() {
        unvisitedClipListView.action
            .bind(with: self) { owner, action in
                switch action {
                case .tap(let index):
                    owner.unvisitedClipListViewModel.action.accept(.tapCell(index))
                case .detail(let index):
                    owner.unvisitedClipListViewModel.action.accept(.tapDetail(index))
                case .edit(let index):
                    owner.unvisitedClipListViewModel.action.accept(.tapEdit(index))
                case .delete(let index):
                    owner.unvisitedClipListViewModel.action.accept(.tapDelete(index))
                }
            }
            .disposed(by: disposeBag)
    }
}
