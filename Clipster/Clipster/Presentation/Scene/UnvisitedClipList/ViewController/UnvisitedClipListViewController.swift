import RxCocoa
import RxSwift
import UIKit

final class UnvisitedClipListViewController: UIViewController {
    private let clips: [Clip]
    private let disposeBag = DisposeBag()

    private let unvisitedClipListView = UnvisitedClipListView()

    init(clips: [Clip]) {
        self.clips = clips
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

        let cellDisplays = clips.map {
            ClipCellDisplay(
                id: $0.id,
                thumbnailImageURL: $0.urlMetadata.thumbnailImageURL,
                title: $0.urlMetadata.title,
                memo: $0.memo,
                isVisited: $0.lastVisitedAt != nil
            )
        }
        unvisitedClipListView.setDisplay(cellDisplays)
    }

    override func loadView() {
        view = unvisitedClipListView
    }
}

private extension UnvisitedClipListViewController {
    func configure() {
        setAttributes()
        setBindings()
    }

    func setAttributes() {
        title = "방문하지 않은 클립"
    }

    func setBindings() {
        unvisitedClipListView.action
            .bind(with: self) { _, action in
                switch action {
                case .tap(let index):
                    print("\(index)번째 클립 탭")
                case .detail(let index):
                    print("\(index)번째 클립 상세")
                case .edit(let index):
                    print("\(index)번째 클립 수정")
                case .delete(let index):
                    print("\(index)번째 클립 삭제")
                }
            }
            .disposed(by: disposeBag)
    }
}
