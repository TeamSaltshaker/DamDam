import SnapKit
import UIKit

final class ClipDetailView: UIView {
    let commonNavigationView = CommonNavigationView()
    let backButton = BackButton()
    let editButton = EditButton()
    let deleteButton = DeleteButton()
    private let urlMetadataView = URLMetadataView()
    private let urlView = URLView()
    private let memoView = MemoView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading {
            memoView.isHidden = true
            activityIndicator.startAnimating()
        } else {
            memoView.isHidden = false
            activityIndicator.stopAnimating()
        }
    }
}

private extension ClipDetailView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .systemBackground

        commonNavigationView.setTitle("폴더 상세정보")
        commonNavigationView.setLeftItem(backButton)
        commonNavigationView.setRightItems([editButton, deleteButton])
    }

    func setHierarchy() {
        [commonNavigationView, urlMetadataView, urlView, memoView, activityIndicator]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        commonNavigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        urlMetadataView.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom).offset(24)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        urlView.snp.makeConstraints { make in
            make.top.equalTo(urlMetadataView.snp.bottom).offset(16)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        memoView.snp.makeConstraints { make in
            make.top.equalTo(urlView.snp.bottom)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
