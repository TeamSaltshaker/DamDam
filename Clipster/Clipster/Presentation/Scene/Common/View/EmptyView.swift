import SnapKit
import UIKit

final class EmptyView: UIView {
    enum EmptyViewType {
        case homeView
        case folderView
        case editClipView

        var imageSize: CGSize {
            switch self {
            case .editClipView:
                return CGSize(width: 54, height: 50)
            default:
                return CGSize(width: 110, height: 100)
            }
        }

        var description: String {
            switch self {
            case .editClipView:
                return "현재 생성된 폴더가 없습니다.\n+버튼으로 추가해 보세요!"
            default:
                return "현재 폴더 및 파일이 없습니다.\n상단 +버튼으로 추가해 보세요!"
            }
        }

        var spacing: CGFloat {
            switch self {
            case .editClipView:
                return 17
            default:
                return 30
            }
        }
    }

    private let emptyViewType: EmptyViewType

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .empty
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 16, weight: .medium)
        label.textColor = .black400
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    init(type: EmptyView.EmptyViewType) {
        self.emptyViewType = type
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EmptyView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .white800

        stackView.spacing = emptyViewType.spacing
        label.text = emptyViewType.description
    }

    func setHierarchy() {
        [imageView, label].forEach {
            stackView.addArrangedSubview($0)
        }
        addSubview(stackView)
    }

    func setConstraints() {
        stackView.snp.makeConstraints { make in
            make.directionalHorizontalEdges.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(200)
        }

        imageView.snp.makeConstraints { make in
            make.width.equalTo(emptyViewType.imageSize.width)
            make.height.equalTo(emptyViewType.imageSize.height)
        }
    }
}
