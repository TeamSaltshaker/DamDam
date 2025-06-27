import RxRelay
import RxSwift
import SnapKit
import UIKit

final class TabBarView: UIView {
    enum Action {
        case tapHome
        case tapUser
        case tapAddFolder
        case tapAddClip
    }

    private let disposeBag = DisposeBag()
    let action = PublishRelay<Action>()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private let homeContainer = UIView()
    private let addContainer = UIView()
    private let userContainer = UIView()

    private let homeButton: UIButton = {
        let button = UIButton()
        button.setImage(.home, for: .normal)
        button.setImage(.homeBlue, for: .selected)
        return button
    }()

    private lazy var addButton: AddButton = {
        let button = AddButton()
        button.showsMenuAsPrimaryAction = true
        button.menu = makeAddButtonMenu()
        return button
    }()

    private let userButton: UIButton = {
        let button = UIButton()
        button.setImage(.user, for: .normal)
        button.setImage(.userBlue, for: .selected)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateSelectedTab(_ mode: TabBarMode) {
        [homeButton, userButton].enumerated().forEach { index, button in
            button.isSelected = (index == mode.rawValue)
        }
    }
}

private extension TabBarView {
    func makeAddButtonMenu() -> UIMenu {
        let addFolderAction = UIAction(
            title: "폴더 추가",
            image: .folderPlus
        ) { [weak self] _ in
            self?.action.accept(.tapAddFolder)
        }

        let addClipAction = UIAction(
            title: "클립 추가",
            image: .clip
        ) { [weak self] _ in
            self?.action.accept(.tapAddClip)
        }

        return UIMenu(title: "", children: [addFolderAction, addClipAction])
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
        backgroundColor = .white900
        layer.cornerRadius = 32
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    func setHierarchy() {
        homeContainer.addSubview(homeButton)
        addContainer.addSubview(addButton)
        userContainer.addSubview(userButton)

        [
            homeContainer,
            addContainer,
            userContainer
        ].forEach { stackView.addArrangedSubview($0) }

        addSubview(stackView)
    }

    func setConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        homeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(24)
        }

        addButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(28)
        }

        userButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(24)
        }
    }

    func setBindings() {
        homeButton.rx.tap
            .map { Action.tapHome }
            .bind(to: action)
            .disposed(by: disposeBag)

        userButton.rx.tap
            .map { Action.tapUser }
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
