import SnapKit
import UIKit

final class SearchClipCell: UICollectionViewListCell {
    private let searchClipRowView = SearchClipRowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setDisplay(_ clip: ClipDisplay, query: String) {
        searchClipRowView.setDisplay(clip, query: query)
    }
}

private extension SearchClipCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        contentView.backgroundColor = .white900
        contentView.layer.cornerRadius = 12
    }

    func setHierarchy() {
        [searchClipRowView]
            .forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        searchClipRowView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
    }
}
