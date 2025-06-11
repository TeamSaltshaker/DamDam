import Foundation
import RxRelay
import RxSwift

final class HomeViewModel {
    enum Action {
        case viewWillAppear
        case tapAddClip
        case tapAddFolder
        case tapCell(IndexPath)
        case tapDetail(IndexPath)
        case tapEdit(IndexPath)
        case tapDelete(IndexPath)
        case tapShowAllClips
    }

    enum State {
        case homeDisplay(HomeDisplay)
    }

    enum Route {
        case showAddClip(Folder?)
        case showAddFolder
        case showWebView(URL)
        case showFolder(Folder)
        case showDetailClip(Clip)
        case showEditClip(Clip)
        case showEditFolder(Folder)
        case showUnvisitedClipList([Clip])
    }

    private let disposeBag = DisposeBag()

    let action = PublishRelay<Action>()
    let state = PublishRelay<State>()
    let route = PublishRelay<Route>()

    private var unvisitedClips: [Clip] = []
    private var folders: [Folder] = []

    private let fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase
    private let fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase
    private let deleteClipUseCase: DeleteClipUseCase
    private let deleteFolderUseCase: DeleteFolderUseCase

    init(
        fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase,
        fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase,
        deleteClipUseCase: DeleteClipUseCase,
        deleteFolderUseCase: DeleteFolderUseCase
    ) {
        self.fetchUnvisitedClipsUseCase = fetchUnvisitedClipsUseCase
        self.fetchTopLevelFoldersUseCase = fetchTopLevelFoldersUseCase
        self.deleteClipUseCase = deleteClipUseCase
        self.deleteFolderUseCase = deleteFolderUseCase
        bind()
    }

    private func bind() {
        action
            .do { print("\(Self.self): received action → \($0)") }
            .subscribe(with: self) { owner, action in
                switch action {
                case .viewWillAppear:
                    Task { await owner.makeHomeDisplay() }
                case .tapAddClip:
                    let latestFolder = owner.folders.max { $0.updatedAt < $1.updatedAt }
                    owner.route.accept(.showAddClip(latestFolder))
                case .tapAddFolder:
                    owner.route.accept(.showAddFolder)
                case .tapCell(let indexPath),
                     .tapDetail(let indexPath),
                     .tapEdit(let indexPath):
                    if let route = owner.route(for: action, at: indexPath) {
                        owner.route.accept(route)
                    }
                case .tapDelete(let indexPath):
                    owner.handleTapDelete(at: indexPath)
                case .tapShowAllClips:
                    owner.route.accept(.showUnvisitedClipList(self.unvisitedClips))
                }
            }
            .disposed(by: disposeBag)
    }

    private func route(for action: Action, at indexPath: IndexPath) -> Route? {
        switch indexPath.section {
        case 0 where indexPath.item < unvisitedClips.count:
            let clip = unvisitedClips[indexPath.item]
            switch action {
            case .tapCell:
                return .showWebView(clip.urlMetadata.url)
            case .tapDetail:
                return .showDetailClip(clip)
            case .tapEdit:
                return .showEditClip(clip)
            default:
                return nil
            }
        case 1 where indexPath.item < folders.count:
            let folder = folders[indexPath.row]
            switch action {
            case .tapCell:
                return .showFolder(folder)
            case .tapEdit:
                return .showEditFolder(folder)
            default:
                return nil
            }
        default:
            return nil
        }
    }

    private func makeHomeDisplay() async {
        do {
            let clipsResult = try await makeClipCellDisplays()
            let foldersResult = try await makeFolderCellDisplays()

            let homeDisplay = HomeDisplay(
                unvitsedClips: clipsResult,
                folders: foldersResult
            )
            state.accept(.homeDisplay(homeDisplay))
        } catch {
            print(error)
        }
    }

    private func makeClipCellDisplays() async throws -> [ClipDisplay] {
        let clips = try await fetchUnvisitedClipsUseCase.execute().get()
        unvisitedClips = clips
        return clips.map { ClipDisplayMapper.map($0) }
    }

    private func makeFolderCellDisplays() async throws -> [FolderDisplay] {
        let folders = try await fetchTopLevelFoldersUseCase.execute().get()
        self.folders = folders
        return folders.map { FolderDisplayMapper.map($0) }
    }

    private func handleTapDelete(at indexPath: IndexPath) {
        switch indexPath.section {
        case 0 where indexPath.item < unvisitedClips.count:
            let clip = unvisitedClips[indexPath.item]
            Task { await delete(clip, with: deleteClipUseCase.execute) }
        case 1 where indexPath.item < folders.count:
            let folder = folders[indexPath.item]
            Task { await delete(folder, with: deleteFolderUseCase.execute) }
        default:
            break
        }
    }

    private func delete<T>(
        _ target: T,
        with execute: @escaping (T) async -> Result<Void, Error>
    ) async {
        let result = await execute(target)
        switch result {
        case .success:
            await makeHomeDisplay()
        case .failure(let error):
            print(error)
        }
    }
}
