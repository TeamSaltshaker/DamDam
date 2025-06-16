import SnapKit
import UIKit

final class EditClipView: UIView {
    let commonNavigationView = CommonNavigationView()
    let backButton = BackButton()
    let saveButton = SaveButton()

    let urlMetadataStackView: URLMetadataStackView = {
        let stackView = URLMetadataStackView(type: .edit)
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

    let urlLabelView = UIView()

    let urlLabel: UILabel = {
        let label = UILabel()
        label.text = "URL"
        label.textColor = .black100
        label.font = .pretendard(size: 16, weight: .medium)
        return label
    }()

    let urlInputTextField: CommonTextField = {
        let textField = CommonTextField()
        textField.keyboardType = .URL
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        textField.attributedPlaceholder = NSAttributedString(
            string: "URL을 입력해 주세요.",
            attributes: [
                .foregroundColor: UIColor.black800,
                .font: UIFont.pretendard(size: 14, weight: .regular)
            ]
        )
        return textField
    }()

    let urlValidationStacKView: URLValidationStackView = {
        let stackView = URLValidationStackView()
        stackView.isHidden = true
        return stackView
    }()

    let memoView = MemoView()

    let folderLabel: UILabel = {
        let label = UILabel()
        label.text = "저장폴더"
        label.textColor = .black100
        label.font = .pretendard(size: 16, weight: .medium)
        return label
    }()

    let addFolderButton = AddButton()

    lazy var folderView: UIView = {
        let view = UIView()
        view.addGestureRecognizer(folderViewTapGesture)
        view.isUserInteractionEnabled = true
        view.backgroundColor = .white900
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    let folderRowView = FolderRowView()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevronRight
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let emptyView = EmptyView(type: .editClipView)

    let folderViewTapGesture = UITapGestureRecognizer()

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
            folderLabel,
            addFolderButton,
            folderView,
            emptyView
        ].forEach {
            scrollContainerView.addSubview($0)
        }

        scrollView.addSubview(scrollContainerView)

        urlLabelView.addSubview(urlLabel)

        [
            urlMetadataStackView,
            urlLabelView,
            urlInputTextField,
            urlValidationStacKView
        ].forEach {
            urlStackView.addArrangedSubview($0)
        }

        [
            folderRowView,
            chevronImageView
        ].forEach {
            folderView.addSubview($0)
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

        urlLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.directionalHorizontalEdges.equalToSuperview().offset(4)
        }

        urlInputTextField.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        memoView.snp.makeConstraints { make in
            make.top.equalTo(urlStackView.snp.bottom).offset(32)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        folderLabel.snp.makeConstraints { make in
            make.top.equalTo(memoView.snp.bottom).offset(40)
            make.leading.equalToSuperview().inset(28)
        }

        addFolderButton.snp.makeConstraints { make in
            make.centerY.equalTo(folderLabel)
            make.trailing.equalToSuperview().inset(28)
            make.size.equalTo(48)
        }

        folderView.snp.makeConstraints { make in
            make.top.equalTo(folderLabel.snp.bottom).offset(24)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.bottom.lessThanOrEqualToSuperview().inset(24)
            make.height.equalTo(72)
        }

        folderRowView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-16)
        }

        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        emptyView.snp.makeConstraints { make in
            make.top.equalTo(folderLabel.snp.bottom).offset(34)
            make.directionalHorizontalEdges.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(22)
        }
    }
}
