import UIKit

final class UnvisitedClipListViewController: UIViewController {
    private let clips: [Clip]

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
        let cellDisplays = clips.map {
            ClipCellDisplay(
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
