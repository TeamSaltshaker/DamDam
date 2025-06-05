import Foundation
import RxRelay
import RxSwift

final class HomeViewModel {
    enum Action {
        case makeHomeDisplay
        case deleteClip(_ clipID: UUID)
    }

    enum State {
        case HomeDisplay(HomeDisplay)
    }

    private let disposeBag = DisposeBag()

    let action = PublishRelay<Action>()
    let state = PublishRelay<State>()

    private let fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase
    private let fetchFolderUseCase: FetchFolderUseCase
    private let deleteClipUseCase: DeleteClipUseCase

    init(
        fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase,
        fetchFolderUseCase: FetchFolderUseCase,
        deleteClipUseCase: DeleteClipUseCase
    ) {
        self.fetchUnvisitedClipsUseCase = fetchUnvisitedClipsUseCase
        self.fetchFolderUseCase = fetchFolderUseCase
        self.deleteClipUseCase = deleteClipUseCase
        bind()
    }

    private func bind() {
        action
            .subscribe(with: self) { owner, action in
                switch action {
                case .makeHomeDisplay:
                    Task { await owner.makeHomeDisplay() }
                case .deleteClip(let id):
                    Task { await owner.deleteClip(id) }
                }
            }
            .disposed(by: disposeBag)
    }

    private func makeHomeDisplay() async {
        async let clipsResult = makeClipCellDisplays()
        async let foldersResult = makeFolderCellDisplays()

        do {
            let homeDisplay = try await HomeDisplay(
                unvitsedClips: clipsResult,
                folders: foldersResult
            )
            state.accept(.HomeDisplay(homeDisplay))
        } catch {
            print(error)
        }
    }

    private func makeClipCellDisplays() async throws -> [ClipCellDisplay] {
        let clips = try await fetchUnvisitedClipsUseCase.execute().get()
        return clips.map {
            ClipCellDisplay(
                thumbnailImageURL: $0.urlMetadata.thumbnailImageURL,
                title: $0.urlMetadata.title,
                memo: $0.memo,
                isVisited: $0.isVisited
            )
        }
    }

    private func makeFolderCellDisplays() async throws -> [FolderCellDisplay] {
        let folder = try await fetchFolderUseCase.execute(parentFolderID: nil).get()
        return folder.folders.map {
            FolderCellDisplay(
                title: $0.title,
                itemCount: $0.clips.count
            )
        }
    }

    private func deleteClip(_ id: UUID) async {
        let result = await deleteClipUseCase.execute(id: id)
        switch result {
        case .success:
            await makeHomeDisplay()
        case .failure(let error):
            print(error)
        }
    }
}
