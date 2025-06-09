import Foundation
import RxRelay
import RxSwift

final class UnvisitedClipListViewModel {
    enum Action {
        case viewDidLoad
        case viewWillAppear
        case tapCell(Int)
        case tapDetail(Int)
        case tapEdit(Int)
        case tapDelete(Int)
    }

    enum State {
        case clips([ClipCellDisplay])
    }

    enum Route {
        case showWebView(URL)
        case showDetailClip(Clip)
        case showEditClip(Clip)
    }
}
