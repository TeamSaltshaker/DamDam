import RxCocoa
import RxSwift
import UIKit

final class UnvisitedClipListViewController: UIViewController {
    private let disposeBag = DisposeBag()

    private let unvisitedClipListViewModel: UnvisitedClipListViewModel
    private let diContainer: DIContainer
    private let unvisitedClipListView = UnvisitedClipListView()

    init(unvisitedClipListViewModel: UnvisitedClipListViewModel, diContainer: DIContainer) {
        self.unvisitedClipListViewModel = unvisitedClipListViewModel
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = unvisitedClipListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unvisitedClipListViewModel.action.accept(.viewWillAppear)
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
                case .tapBack:
                    owner.unvisitedClipListViewModel.action.accept(.tapBack)
                case .tapCell(let index):
                    owner.unvisitedClipListViewModel.action.accept(.tapCell(index))
                case .detail(let index):
                    owner.unvisitedClipListViewModel.action.accept(.tapDetail(index))
                case .edit(let index):
                    owner.unvisitedClipListViewModel.action.accept(.tapEdit(index))
                case .delete(let index, let title):
                    owner.presentDeleteAlert(title: title) { [weak self] in
                        self?.unvisitedClipListViewModel.action.accept(.tapDelete(index))
                    }
                }
            }
            .disposed(by: disposeBag)

        unvisitedClipListViewModel.state
            .asSignal()
            .emit(with: self) { owner, state in
                switch state {
                case .clips(let clips):
                    owner.unvisitedClipListView.setDisplay(clips)
                }
            }
            .disposed(by: disposeBag)

        unvisitedClipListViewModel.route
            .asSignal()
            .emit(with: self) { owner, route in
                switch route {
                case .back:
                    owner.navigationController?.popViewController(animated: true)
                case .showWebView(let url):
                    print("웹 뷰")
                    print("\(url)\n")
                case .showDetailClip(let clip):
                    let vm = owner.diContainer.makeClipDetailViewModel(clip: clip)
                    let vc = ClipDetailViewController(
                        viewModel: vm,
                        diContainer: owner.diContainer
                    )
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .showEditClip(let clip):
                    let vm = owner.diContainer.makeEditClipViewModel(clip: clip)
                    let vc = EditClipViewController(
                        viewModel: vm,
                        diContainer: owner.diContainer
                    )
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}
