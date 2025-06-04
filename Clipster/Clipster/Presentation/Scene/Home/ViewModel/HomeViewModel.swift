import Foundation
import RxRelay
import RxSwift

final class HomeViewModel {
    enum Action {
        case fetchHomeDisplay
        case deleteClip(_ clipID: UUID)
    }

    enum State {
        case HomeDisplay(HomeDisplay)
    }

    private let disposeBag = DisposeBag()

    let action = PublishRelay<Action>()
    let state = PublishRelay<State>()

    private let fetchUnvisitedClipUseCase: FetchUnvisitedClipUseCase
    private let fetchFolderUseCase: FetchFolderUseCase
    private let deleteClipUseCase: DeleteClipUseCase

    init(
        fetchUnvisitedClipUseCase: FetchUnvisitedClipUseCase,
        fetchFolderUseCase: FetchFolderUseCase,
        deleteClipUseCase: DeleteClipUseCase
    ) {
        self.fetchUnvisitedClipUseCase = fetchUnvisitedClipUseCase
        self.fetchFolderUseCase = fetchFolderUseCase
        self.deleteClipUseCase = deleteClipUseCase
        bind()
    }

    private func bind() {
        action
            .subscribe(with: self) { owner, action in
                switch action {
                case .fetchHomeDisplay:
                    Task { await owner.fetchHomeDisPlay() }
                case .deleteClip(let id):
                    Task { await owner.deleteClip(id) }
                }
            }
            .disposed(by: disposeBag)
    }

    private func fetchHomeDisPlay() async {
        async let rootFolder = fetchRootFolder()
        async let unvisitedClips = fetchUnvisitedClip()

        do {
            let homeDisplay = try await HomeDisplay(
                unvitsedClips: unvisitedClips,
                folders: rootFolder.folders,
                clips: rootFolder.clips
            )
            state.accept(.HomeDisplay(homeDisplay))
        } catch {
            print(error)
        }
    }

    private func fetchRootFolder() async throws -> Folder {
        let result = await fetchFolderUseCase.execute(parentFolderID: nil)
        switch result {
        case .success(let folder):
            return folder
        case .failure(let error):
            throw error
        }
    }

    private func fetchUnvisitedClip() async throws -> [Clip] {
        let result = await fetchUnvisitedClipUseCase.execute()
        switch result {
        case .success(let clip):
            return clip
        case .failure(let error):
            throw error
        }
    }

    private func deleteClip(_ id: UUID) async {
        let result = await deleteClipUseCase.execute(id: id)
        switch result {
        case .success:
            await fetchHomeDisPlay()
        case .failure(let error):
            print(error)
        }
    }
}
