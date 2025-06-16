import SnapKit
import UIKit

final class EditClipView: UIView {
    let commonNavigationView = CommonNavigationView()
    let backButton = BackButton()
    let saveButton = SaveButton()

    let urlMetadataStackView: URLMetadataStackView = {
        let stackView = URLMetadataStackView()
        stackView.isHidden = true
        return stackView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let scrollContainerView = UIView()

    private let urlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    let urlView: URLView = {
        let view = URLView()
        view.urlTextField.mode = .edit
        return view
    }()

    let urlValidationStacKView: URLValidationStackView = {
        let stackView = URLValidationStackView()
        stackView.isHidden = true
        return stackView
    }()

    let memoView = MemoView()

    let selectedFolderView = SelectedFolderView(mode: .edit)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EditClipView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        commonNavigationView.setLeftItem(backButton)
        commonNavigationView.setRightItem(saveButton)
    }

    func setHierarchy() {
        [
            urlStackView,
            memoView,
            selectedFolderView
        ].forEach {
            scrollContainerView.addSubview($0)
        }

        scrollView.addSubview(scrollContainerView)

        [
            urlMetadataStackView,
            urlView,
            urlValidationStacKView
        ].forEach {
            urlStackView.addArrangedSubview($0)
        }

        [
            commonNavigationView,
            scrollView
        ].forEach {
            addSubview($0)
        }
    }

    func setConstraints() {
        commonNavigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom)
            make.directionalHorizontalEdges.equalToSuperview()
            make.bottom.equalTo(keyboardLayoutGuide.snp.top)
            make.width.equalToSuperview()
        }

        scrollContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        urlStackView.setCustomSpacing(32, after: urlStackView.arrangedSubviews[0])

        urlStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.width.equalToSuperview().inset(24)
            make.height.equalTo(0).priority(.low)
        }

        memoView.snp.makeConstraints { make in
            make.top.equalTo(urlStackView.snp.bottom).offset(32)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        selectedFolderView.snp.makeConstraints { make in
            make.top.equalTo(memoView.snp.bottom).offset(40)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.bottom.lessThanOrEqualToSuperview().inset(24)
        }
    }
}
