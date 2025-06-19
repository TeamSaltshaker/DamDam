import Kingfisher
import SnapKit
import UIKit

final class ClipDetailView: UIView {
    let commonNavigationView = CommonNavigationView()
    let backButton = BackButton()
    let editButton = EditButton()
    let deleteButton = DeleteButton()

    private let urlMetadataStackView = URLMetadataStackView()

    private let urlView: URLView = {
        let view = URLView()
        view.urlTextField.mode = .detail
        return view
    }()

    private let memoView: MemoView = {
        let view = MemoView()
        view.memoTextView.textColor = .black500
        view.memoTextView.isEditable = false
        return view
    }()

    private let selectedFolderView = SelectedFolderView(type: .clip, mode: .detail)

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(_ clip: ClipDisplay, folder: FolderDisplay) {
        urlMetadataStackView.setDisplay(display: clip.urlMetadata)
        urlView.urlTextField.text = clip.urlMetadata.url.description
        memoView.memoTextView.text = clip.memo
        memoView.memoLimitLabel.text = clip.memoLimit
        selectedFolderView.folderRowView.setDisplay(folder)
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
        backgroundColor = .white800

        commonNavigationView.setTitle("상세정보")
        commonNavigationView.setLeftItem(backButton)
        commonNavigationView.setRightItems([editButton, deleteButton])
    }

    func setHierarchy() {
        [commonNavigationView, urlMetadataStackView, urlView, memoView, selectedFolderView, activityIndicator]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        commonNavigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        editButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        deleteButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        urlMetadataStackView.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom).offset(24)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        urlView.snp.makeConstraints { make in
            make.top.equalTo(urlMetadataStackView.snp.bottom).offset(32)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        memoView.snp.makeConstraints { make in
            make.top.equalTo(urlView.snp.bottom).offset(32)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        selectedFolderView.snp.makeConstraints { make in
            make.top.equalTo(memoView.snp.bottom).offset(40)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.bottom.lessThanOrEqualToSuperview().inset(24)
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
