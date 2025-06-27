import RxRelay
import RxSwift
import SnapKit
import UIKit

final class CollectionHeaderView: UICollectionReusableView {
    let showAllTapped = PublishRelay<Void>()
    private(set) var disposeBag = DisposeBag()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .init(name: "Pretendard-SemiBold", size: 18)
        label.textColor = .black100
        return label
    }()

    private let showAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("전체보기", for: .normal)
        button.setTitleColor(.black500, for: .normal)
        button.titleLabel?.font = .init(name: "Pretendard-Medium", size: 14)
        button.titleLabel?.textAlignment = .center
        button.isHidden = true
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        showAllButton.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    func setShowAllButtonVisible(_ isVisible: Bool) {
        showAllButton.isHidden = !isVisible
    }

    func setBindings() {
        disposeBag = DisposeBag()
        showAllButton.rx.tap
            .bind(to: showAllTapped)
            .disposed(by: disposeBag)
    }
}

private extension CollectionHeaderView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [
            titleLabel,
            showAllButton
        ].forEach { addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview().inset(4)
        }

        showAllButton.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.greaterThanOrEqualTo(titleLabel).offset(12)
            make.trailing.equalToSuperview().inset(3.49)
        }
    }
}
