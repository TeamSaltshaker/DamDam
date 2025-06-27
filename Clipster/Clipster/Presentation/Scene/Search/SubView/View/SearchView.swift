import SnapKit
import UIKit

final class SearchView: UIView {
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(.chevronLeft, for: .normal)
        button.contentHorizontalAlignment = .left
        return button
    }()

    let searchTextField = SearchTextField()

    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    let emptyView: EmptyView = {
        let view = EmptyView(type: .searchView)
        view.isHidden = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCollecrtionViewLayout(layout: UICollectionViewLayout) {
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
}

private extension SearchView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .white800
    }

    func setHierarchy() {
        [backButton, searchTextField, collectionView, emptyView]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(searchTextField)
            make.leading.equalToSuperview().offset(24)
            make.size.equalTo(46)
        }

        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(4)
            make.leading.equalTo(backButton.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(20)
            make.directionalHorizontalEdges.bottom.equalToSuperview()
        }

        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
