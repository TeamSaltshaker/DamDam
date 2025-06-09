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

    private let disposeBag = DisposeBag()

    let action = PublishRelay<Action>()
    let state = PublishRelay<State>()
    let route = PublishRelay<Route>()

    private var clips: [Clip]

    private let fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase
    private let deleteClipUseCase: DeleteClipUseCase

    init(
        clips: [Clip],
        fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase,
        deleteClipUseCase: DeleteClipUseCase
    ) {
        self.clips = clips
        self.fetchUnvisitedClipsUseCase = fetchUnvisitedClipsUseCase
        self.deleteClipUseCase = deleteClipUseCase
        bind()
    }

    private func bind() {
        action
            .do { print("\(Self.self): received action → \($0)") }
            .subscribe(with: self) { owner, action in
                switch action {
                case .viewDidLoad:
                    break
                case .viewWillAppear:
                    break
                case .tapCell(let index),
                     .tapDetail(let index),
                     .tapEdit(let index):
                    break
                case .tapDelete(let index):
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}
