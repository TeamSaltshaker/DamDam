import Foundation
import RxRelay
import RxSwift

final class UnvisitedClipListViewModel {
    enum Action {
        case viewWillAppear
        case tapBack
        case tapCell(Int)
        case tapDetail(Int)
        case tapEdit(Int)
        case tapDelete(Int)
    }

    enum State {
        case clips([ClipDisplay])
    }

    enum Route {
        case back
        case showWebView(URL)
        case showDetailClip(Clip)
        case showEditClip(Clip)
    }

    private let disposeBag = DisposeBag()

    let action = PublishRelay<Action>()
    let state = PublishRelay<State>()
    let route = PublishRelay<Route>()

    private var clips: [Clip]
    private var shouldFetchOnAppear: Bool = false

    private let fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase
    private let deleteClipUseCase: DeleteClipUseCase
    private let updateClipUseCase: UpdateClipUseCase

    init(
        clips: [Clip],
        fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase,
        deleteClipUseCase: DeleteClipUseCase,
        updateClipUseCase: UpdateClipUseCase
    ) {
        self.clips = clips
        self.fetchUnvisitedClipsUseCase = fetchUnvisitedClipsUseCase
        self.deleteClipUseCase = deleteClipUseCase
        self.updateClipUseCase = updateClipUseCase
        bind()
    }

    private func bind() {
        action
            .do { print("\(Self.self): received action → \($0)") }
            .subscribe(with: self) { owner, action in
                switch action {
                case .viewWillAppear:
                    Task { await owner.handleViewWillAppear() }
                case .tapBack:
                    owner.route.accept(.back)
                case .tapCell(let index),
                     .tapDetail(let index),
                     .tapEdit(let index):
                    if let route = owner.route(for: action, at: index) {
                        owner.route.accept(route)
                    }
                case .tapDelete(let index):
                    guard index < owner.clips.count else { break }
                    Task { await owner.deleteClip(owner.clips[index]) }
                }
            }
            .disposed(by: disposeBag)
    }

    private func handleViewWillAppear() async {
        if shouldFetchOnAppear {
            let result = await fetchUnvisitedClipsUseCase.execute()
            switch result {
            case .success(let clips):
                let cellDisplay = clips.map(ClipDisplayMapper.map)
                state.accept(.clips(cellDisplay))
            case .failure(let error):
                print(error)
            }
        } else {
            shouldFetchOnAppear = true
            let cellDisplay = clips.map(ClipDisplayMapper.map)
            state.accept(.clips(cellDisplay))
        }
    }

    private func route(for action: Action, at index: Int) -> Route? {
        guard index < clips.count else { return nil }

        let clip = clips[index]
        switch action {
        case .tapCell:
            Task { await updateClipAsVisited(clip) }
            return .showWebView(clip.urlMetadata.url)
        case .tapDetail:
            return .showDetailClip(clip)
        case .tapEdit:
            return .showEditClip(clip)
        default:
            return nil
        }
    }

    private func deleteClip(_ clip: Clip) async {
        let result = await deleteClipUseCase.execute(clip)
        switch result {
        case .success:
            await handleViewWillAppear()
        case .failure(let error):
            print(error)
        }
    }

    private func updateClipAsVisited(_ clip: Clip) async {
        let visitedClip = Clip(
            id: clip.id,
            folderID: clip.folderID,
            urlMetadata: clip.urlMetadata,
            memo: clip.memo,
            lastVisitedAt: Date(),
            createdAt: clip.createdAt,
            updatedAt: clip.updatedAt,
            deletedAt: clip.deletedAt
        )

        let result = await updateClipUseCase.execute(clip: visitedClip)
        switch result {
        case .success:
            break
        case .failure(let error):
            print(error)
        }
    }
}
