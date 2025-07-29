import SnapKit
import UIKit

final class EmptyStateView: UIView {
    enum ViewType {
        case homeView
        case folderView
        case searchView

        var imageSize: CGSize {
            switch self {
            default:
                return CGSize(width: 110, height: 100)
            }
        }

        var description: String {
            switch self {
            case .searchView:
                return "검색된 폴더 및 파일이 없습니다."
            default:
                return "현재 폴더 및 파일이 없습니다."
            }
        }

        var spacing: CGFloat {
            switch self {
            default:
                return 30
            }
        }
    }

    private let viewType: ViewType

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .empty
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 16, weight: .medium)
        label.textColor = .textSecondary
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    init(type: EmptyStateView.ViewType) {
        self.viewType = type
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EmptyStateView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .background

        descriptionLabel.text = viewType.description
    }

    func setHierarchy() {
        [imageView, descriptionLabel].forEach {
            addSubview($0)
        }
    }

    func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalTo(viewType.imageSize.width)
            make.height.equalTo(viewType.imageSize.height)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(viewType.spacing)
            make.directionalHorizontalEdges.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
