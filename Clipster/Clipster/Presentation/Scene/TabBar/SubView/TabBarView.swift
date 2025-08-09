import RxRelay
import RxSwift
import SnapKit
import UIKit

final class TabBarView: UIView {
    enum Action {
        case tap(TabItem)
    }

    private let disposeBag = DisposeBag()
    let action = PublishRelay<Action>()

    private let items = TabItem.allCases

    private let baseBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .cell
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var containerViews: [TabItem: UIView] = {
        Dictionary(uniqueKeysWithValues: items.map { ($0, UIView()) })
    }()

    private lazy var tabButtons: [TabItem: UIButton] = {
        Dictionary(uniqueKeysWithValues: items.map { mode in
            let button = UIButton()
            button.setImage(mode.unselectedImage.withTintColor(.textPrimary), for: .normal)
            button.setImage(mode.selectedImage, for: .selected)
            return (mode, button)
        })
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: layer.cornerRadius
        )
        layer.shadowPath = path.cgPath
    }

    func updateSelectedTab(_ mode: TabItem) {
        tabButtons.forEach { key, button in
            button.isSelected = (key == mode)
        }
    }
}

private extension TabBarView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
        setBindings()
    }

    func setAttributes() {
        backgroundColor = .background

        layer.cornerRadius = 32
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowRadius = 7
        layer.masksToBounds = false
    }

    func setHierarchy() {
        addSubview(baseBackgroundView)
        addSubview(stackView)

        items.forEach { mode in
            guard let container = containerViews[mode],
                  let button = tabButtons[mode]
            else { return }

            stackView.addArrangedSubview(container)
            container.addSubview(button)
        }
    }

    func setConstraints() {
        baseBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tabButtons.forEach { _, button in
            button.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.horizontalEdges.equalToSuperview()
                make.height.equalTo(64)
            }
        }
    }

    func setBindings() {
        Observable.merge(
            tabButtons.map { (mode, button) in
                button.rx.tap.map { Action.tap(mode) }
            }
        )
        .bind(to: action)
        .disposed(by: disposeBag)
    }
}
