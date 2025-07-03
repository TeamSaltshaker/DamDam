import MessageUI
import ReactorKit
import UIKit

final class MyPageViewController: UIViewController, View {
    typealias Reactor = MyPageReactor

    var disposeBag = DisposeBag()
    private let myPageView = MyPageView()
    private weak var coordinator: MyPageCoordinator?

    init(reactor: Reactor, coordinator: MyPageCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = myPageView
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

extension MyPageViewController {
    func bindAction(to reactor: Reactor) {
        myPageView.action
            .bind { action in
                switch action {
                case .tapCell(let item):
                    reactor.action.onNext(.tapCell(item))
                }
            }
            .disposed(by: disposeBag)
    }

    func bindState(from reactor: Reactor) {
        reactor.state
            .map { $0.sectionModel }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] sections in
                self?.myPageView.setDisplay(sections)
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$phase)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] phase in
                guard let self else { return }

                switch phase {
                case .loading:
                    myPageView.showLoading()
                case .success:
                    myPageView.hideLoading()
                case .error(let message):
                    myPageView.hideLoading()
                    presentErrorAlert(message: message)
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
                case .showEditNickName:
                    break
                case .showSelectTheme:
                    break
                case .showSelectFolderSort:
                    break
                case .showSelectClipSort:
                    break
                case .showSelectSavePathLayout:
                    break
                case .showNotificationSetting:
                    coordinator?.showAppSettings()
                case .showTrash:
                    break
                case .showSupport:
                    coordinator?.showInquiryMail()
                }
            }
            .disposed(by: disposeBag)
    }
}
