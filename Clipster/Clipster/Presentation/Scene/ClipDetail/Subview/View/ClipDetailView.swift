import Kingfisher
import SnapKit
import UIKit

final class ClipDetailView: UIView {
    let commonNavigationView = CommonNavigationView()
    let backButton = BackButton()
    let editButton = EditButton()
    let deleteButton = DeleteButton()
    private let thumbnailView = ThumbnailView()

    private let urlView: URLView = {
        let view = URLView()
        view.urlTextField.textColor = .black500
        return view
    }()

    private let memoView: MemoView = {
        let view = MemoView()
        view.memoTextView.textColor = .black500
        return view
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let folderLabel: UILabel = {
        let label = UILabel()
        label.text = "저장폴더"
        label.textColor = .black100
        label.font = .pretendard(size: 16, weight: .medium)
        return label
    }()

    let folderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white900
        view.layer.cornerRadius = 12
        return view
    }()

    private let folderRowView = FolderRowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(_ clip: ClipDisplay, folder: FolderDisplay) {
        thumbnailView.thumbnailImageView.kf.setImage(with: clip.urlMetadata.thumbnailImageURL)
        thumbnailView.titleLabel.text = clip.urlMetadata.title
        urlView.urlTextField.text = clip.urlMetadata.url.description
        memoView.memoTextView.text = clip.memo
        memoView.memoLimitLabel.text = clip.memoLimit
        folderRowView.setDisplay(folder)
    }

    func setInteraction(enabled: Bool) {
        thumbnailView.isUserInteractionEnabled = enabled
        urlView.isUserInteractionEnabled = enabled
        memoView.isUserInteractionEnabled = enabled

        if enabled {
            urlView.urlTextField.textColor = .black50
            memoView.memoTextView.textColor = .black50
        } else {
            urlView.urlTextField.textColor = .black500
            memoView.memoTextView.textColor = .black500
        }
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

        commonNavigationView.setTitle("클립 상세정보")
        commonNavigationView.setLeftItem(backButton)
        commonNavigationView.setRightItems([editButton, deleteButton])
    }

    func setHierarchy() {
        [commonNavigationView, thumbnailView, urlView, memoView, folderLabel, folderView, activityIndicator]
            .forEach { addSubview($0) }

        folderView.addSubview(folderRowView)
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

        thumbnailView.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom).offset(24)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        urlView.snp.makeConstraints { make in
            make.top.equalTo(thumbnailView.snp.bottom).offset(32)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        memoView.snp.makeConstraints { make in
            make.top.equalTo(urlView.snp.bottom).offset(32)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        folderLabel.snp.makeConstraints { make in
            make.top.equalTo(memoView.snp.bottom).offset(40)
            make.directionalHorizontalEdges.equalToSuperview().inset(28)
        }

        folderView.snp.makeConstraints { make in
            make.top.equalTo(folderLabel.snp.bottom).offset(24)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(72)
        }

        folderRowView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.directionalHorizontalEdges.equalToSuperview().inset(20)
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
