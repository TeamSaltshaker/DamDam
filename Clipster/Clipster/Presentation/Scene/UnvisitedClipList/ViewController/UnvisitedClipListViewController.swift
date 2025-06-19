import ReactorKit
import SafariServices
import UIKit

final class UnvisitedClipListViewController: UIViewController, View {
    typealias Reactor = UnvisitedClipListReactor

    var disposeBag = DisposeBag()
    private let unvisitedClipListView = UnvisitedClipListView()
    private let diContainer: DIContainer

    init(reactor: Reactor, diContainer: DIContainer) {
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = unvisitedClipListView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        reactor?.action.onNext(.viewWillAppear)
    }

    func bind(reactor: Reactor) {
        bindAction(to: reactor)
        bindState(from: reactor)
        bindRoute(from: reactor)
    }
}

extension UnvisitedClipListViewController {
    func bindAction(to reactor: Reactor) {
        unvisitedClipListView.action
            .bind { [weak self] action in
                switch action {
                case .tapBack:
                    reactor.action.onNext(.tapBack)
                case .tapCell(let index):
                    reactor.action.onNext(.tapCell(index))
                case .detail(let index):
                    reactor.action.onNext(.tapDetail(index))
                case .edit(let index):
                    reactor.action.onNext(.tapEdit(index))
                case .delete(let index, let title):
                    self?.presentDeleteAlert(title: title) {
                        reactor.action.onNext(.tapDelete(index))
                    }
                }
            }
            .disposed(by: disposeBag)
    }

    func bindState(from reactor: Reactor) {
        reactor.state
            .compactMap { $0.clips }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] display in
                self?.unvisitedClipListView.setDisplay(display)
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$phase)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] phase in
                guard let self else { return }

                switch phase {
                case .loading:
                    unvisitedClipListView.showLoading()
                case .success:
                    unvisitedClipListView.hideLoading()
                case .error(let message):
                    let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    present(alert, animated: true)
                case .idle:
                    break
                }
            }
            .disposed(by: disposeBag)
    }

    func bindRoute(from reactor: Reactor) {
        reactor.pulse(\.$route)
            .compactMap { $0 }
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] route in
                guard let self else { return }

                switch route {
                case .back:
                    navigationController?.popViewController(animated: true)
                case .showWebView(let url):
                    let vc = SFSafariViewController(url: url)
                    present(vc, animated: true)
                case .showDetailClip(let clip):
                    let reactor = self.diContainer.makeClipDetailReactor(clip: clip)
                    let vc = ClipDetailViewController(
                        reactor: reactor,
                        diContainer: self.diContainer
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                case .showEditClip(let clip):
                    let reactor = diContainer.makeEditClipReactor(clip: clip)
                    let vc = EditClipViewController(
                        reactor: reactor,
                        diContainer: diContainer
                    )
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension UnvisitedClipListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
