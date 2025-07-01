import SnapKit
import UIKit

final class ShareView: UIView {
    let commonNavigationView: CommonNavigationView = {
        let commonNavigationView = CommonNavigationView()
        commonNavigationView.backgroundColor = .white900
        commonNavigationView.setTitle("클립 추가")
        return commonNavigationView
    }()

    let cancelButton = CancelButton()
    let saveButton = SaveButton()

    let scrollView: UIScrollView = {
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

    let urlMetadataStackView: URLMetadataStackView = {
        let stackView = URLMetadataStackView()
        stackView.isHidden = true
        return stackView
    }()

    let urlTextField: CommonTextField = {
        let textField = CommonTextField(type: .clip)
        textField.mode = .edit
        return textField
    }()

    let urlValidationStacKView: URLValidationStackView = {
        let stackView = URLValidationStackView()
        stackView.isHidden = true
        return stackView
    }()

    let memoView = MemoView()

    let selectedFolderView = SelectedFolderView(type: .clip, mode: .edit)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ShareView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .white900

        commonNavigationView.setLeftItem(cancelButton)
        commonNavigationView.setRightItem(saveButton)
    }

    func setHierarchy() {
        [
            commonNavigationView,
            scrollView
        ].forEach {
            addSubview($0)
        }

        [
            scrollContainerView
        ].forEach {
            scrollView.addSubview($0)
        }

        [
            urlStackView,
            memoView,
            selectedFolderView
        ].forEach {
            scrollContainerView.addSubview($0)
        }

        [
            urlMetadataStackView,
            urlTextField,
            urlValidationStacKView
        ].forEach {
            urlStackView.addArrangedSubview($0)
        }
    }

    func setConstraints() {
        commonNavigationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        saveButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom)
            make.directionalHorizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        scrollContainerView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        urlStackView.setCustomSpacing(32, after: urlStackView.arrangedSubviews[0])

        urlStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.width.equalToSuperview().inset(24)
            make.height.equalTo(0).priority(.low)
        }

        urlTextField.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        memoView.snp.makeConstraints { make in
            make.top.equalTo(urlStackView.snp.bottom).offset(32)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        selectedFolderView.snp.makeConstraints { make in
            make.top.equalTo(memoView.snp.bottom).offset(40)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalToSuperview()
        }
    }
}
