import ReactorKit
import UIKit

final class HomeViewController: UIViewController, View {
    typealias Reactor = HomeReactor

    var disposeBag = DisposeBag()
    private let homeView = HomeView()
    private weak var coordinator: HomeCoordinator?

    init(reactor: Reactor, coordinator: HomeCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = homeView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.viewWillAppear)
    }

    func bind(reactor: Reactor) {
        bindAction(to: reactor)
        bindState(from: reactor)
        bindRoute(from: reactor)
    }
}

private extension HomeViewController {
    func bindAction(to reactor: Reactor) {
        homeView.action
            .bind { [weak self] action in
                switch action {
                case .tapAddFolder:
                    reactor.action.onNext(.tapAddFolder)
                case .tapAddClip:
                    reactor.action.onNext(.tapAddClip)
                case .tapCell(let indexPath):
                    reactor.action.onNext(.tapCell(indexPath))
                case .detail(let indexPath):
                    reactor.action.onNext(.tapDetail(indexPath))
                case .edit(let indexPath):
                    reactor.action.onNext(.tapEdit(indexPath))
                case .delete(let indexPath, let title):
                    self?.presentDeleteAlert(title: title) {
                        reactor.action.onNext(.tapDelete(indexPath))
                    }
                case .showAllClips:
                    reactor.action.onNext(.tapShowAllClips)
                }
            }
            .disposed(by: disposeBag)
    }

    func bindState(from reactor: Reactor) {
        reactor.state
            .compactMap { $0.homeDisplay }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] display in
                self?.homeView.setDisplay(display)
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$phase)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] phase in
                guard let self else { return }

                switch phase {
                case .loading:
                    homeView.showLoading()
                case .success:
                    homeView.hideLoading()
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
            .observe(on: MainScheduler.instance)
            .bind { [weak self] route in
                guard let self else { return }

                switch route {
                case .showAddClip(let folder):
                    coordinator?.showAddClip(folder: folder)
                case .showAddFolder:
                    coordinator?.showAddFolder()
                case .showWebView(let url):
                    coordinator?.showWebView(url: url)
                case .showFolder(let folder):
                    coordinator?.showFolder(folder: folder)
                case .showDetailClip(let clip):
                    coordinator?.showDetailClip(clip: clip)
                case .showEditClip(let clip):
                    coordinator?.showEditClip(clip: clip)
                case .showEditFolder(let folder):
                    coordinator?.showEditFolder(folder: folder)
                case .showUnvisitedClipList(let clips):
                    coordinator?.showUnvisitedClipList(clips: clips)
                }
            }
            .disposed(by: disposeBag)
    }
}
