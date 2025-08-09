import RxRelay
import RxSwift
import SnapKit
import UIKit

final class TabBarViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let tabBarView = TabBarView()
    private weak var coordinator: TabBarCoordinator?

    private var currentVC: UIViewController?
    private let selectedTab = BehaviorRelay<TabItem>(value: .defaultTab)

    private var lastTabBarHeight: CGFloat = 0

    init(coordinator: TabBarCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let baseTabBarHeight: CGFloat = 64
        let bottomInset = view.safeAreaInsets.bottom
        let tabBarHeight = baseTabBarHeight + bottomInset

        guard lastTabBarHeight != tabBarHeight else { return }

        lastTabBarHeight = tabBarHeight
        tabBarView.snp.updateConstraints { make in
            make.height.equalTo(tabBarHeight)
        }
    }

    func switchTo(_ vc: UIViewController) {
        currentVC?.willMove(toParent: nil)
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()

        addChild(vc)
        view.insertSubview(vc.view, belowSubview: tabBarView)

        vc.view.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(tabBarView.snp.top)
        }

        vc.didMove(toParent: self)
        currentVC = vc
    }
}

private extension TabBarViewController {
    func configure() {
        setHierarchy()
        setConstraints()
        setBindings()
    }

    func setHierarchy() {
        view.backgroundColor = .background
        view.addSubview(tabBarView)
    }

    func setConstraints() {
        tabBarView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    func setBindings() {
        tabBarView.action
            .bind { [weak self] action in
                switch action {
                case .tap(let mode):
                    self?.selectedTab.accept(mode)
                }
            }
            .disposed(by: disposeBag)

        selectedTab
            .distinctUntilChanged()
            .subscribe { [weak self] mode in
                guard let self else { return }

                tabBarView.updateSelectedTab(mode)
                coordinator?.didSelect(tab: mode)
            }
            .disposed(by: disposeBag)
    }
}
