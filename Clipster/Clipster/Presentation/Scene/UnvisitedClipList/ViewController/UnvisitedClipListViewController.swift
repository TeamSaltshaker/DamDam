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
            .emit(with: self) { _, route in
                switch route {
                case .showWebView(let url):
                    print("웹 뷰")
                    print("\(url)\n")
                case .showDetailClip(let clip):
                    print("클립 상세 화면 이동")
                    print("\(clip)\n")
                case .showEditClip(let clip):
                    print("클립 편집 화면 이동")
                    print("\(clip)\n")
                }
            }
            .disposed(by: disposeBag)
    }
}
