import CoreData
import Foundation

final class DIContainer {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer? = nil) {
        self.container = container ?? CoreDataStack.shared.container
    }

    func makeClipStorage() -> ClipStorage {
         DefaultClipStorage(container: container, mapper: DomainMapper())
     }

    func makeFolderStorage() -> FolderStorage {
         DefaultFolderStorage(container: container, mapper: DomainMapper())
     }

    func makeClipRepository() -> ClipRepository {
        DefaultClipRepository(storage: makeClipStorage())
    }

    func makeFolderRepository() -> FolderRepository {
        DefaultFolderRepository(storage: makeFolderStorage())
    }

    func makeURLRepository() -> URLRepository {
        DefaultURLRepository()
    }

    func makeCreateClipUseCase() -> CreateClipUseCase {
        DefaultCreateClipUseCase(clipRepository: makeClipRepository())
    }

    func makeUpdateClipUseCase() -> UpdateClipUseCase {
        DefaultUpdateClipUseCase(clipRepository: makeClipRepository())
    }

    func makeDeleteClipUseCase() -> DeleteClipUseCase {
        DefaultDeleteClipUseCase(clipRepository: makeClipRepository())
    }

    func makeFetchClipUseCase() -> FetchClipUseCase {
        DefaultFetchClipUseCase(clipRepository: makeClipRepository())
    }

    func makeFetchUnvisitedClipsUseCase() -> FetchUnvisitedClipsUseCase {
        DefaultFetchUnvisitedClipsUseCase(clipRepository: makeClipRepository())
    }

    func makeCreateFolderUseCase() -> CreateFolderUseCase {
        DefaultCreateFolderUseCase(folderRepository: makeFolderRepository())
    }

    func makeDeleteFolderUseCase() -> DeleteFolderUseCase {
        DefaultDeleteFolderUseCase(folderRepository: makeFolderRepository())
    }

    func makeFetchFolderUseCase() -> FetchFolderUseCase {
        DefaultFetchFolderUseCase(folderRepository: makeFolderRepository())
    }

    func makeFetchTopLevelFoldersUseCase() -> FetchTopLevelFoldersUseCase {
        DefaultFetchTopLevelFoldersUseCase(folderRepository: makeFolderRepository())
    }

    func makeUpdateFolderUseCase() -> UpdateFolderUseCase {
        DefaultUpdateFolderUseCase(folderRepository: makeFolderRepository())
    }

    func makeParseURLUseCase() -> ParseURLUseCase {
        DefaultParseURLUseCase(urlRepository: makeURLRepository())
    }

    func makeClipDetailViewModel(clip: Clip) -> ClipDetailViewModel {
        ClipDetailViewModel(
            fetchFolderUseCase: makeFetchFolderUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase(),
            fetchClipUseCase: makeFetchClipUseCase(),
            clip: clip,
        )
    }

    func makeEditClipViewModel() -> EditClipViewModel {
        EditClipViewModel(
            parseURLUseCase: makeParseURLUseCase(),
            fetchFolderUseCase: makeFetchFolderUseCase(),
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            createClipUseCase: makeCreateClipUseCase(),
            updateClipUseCase: makeUpdateClipUseCase()
        )
    }

    func makeEditClipViewModel(urlString: String) -> EditClipViewModel {
        EditClipViewModel(
            urlText: urlString,
            parseURLUseCase: makeParseURLUseCase(),
            fetchFolderUseCase: makeFetchFolderUseCase(),
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            createClipUseCase: makeCreateClipUseCase(),
            updateClipUseCase: makeUpdateClipUseCase()
        )
    }

    func makeEditClipViewModel(folder: Folder?) -> EditClipViewModel {
        EditClipViewModel(
            currentFolder: folder,
            parseURLUseCase: makeParseURLUseCase(),
            fetchFolderUseCase: makeFetchFolderUseCase(),
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            createClipUseCase: makeCreateClipUseCase(),
            updateClipUseCase: makeUpdateClipUseCase()
        )
    }

    func makeEditClipViewModel(clip: Clip) -> EditClipViewModel {
        EditClipViewModel(
            clip: clip,
            parseURLUseCase: makeParseURLUseCase(),
            fetchFolderUseCase: makeFetchFolderUseCase(),
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            createClipUseCase: makeCreateClipUseCase(),
            updateClipUseCase: makeUpdateClipUseCase()
        )
    }

    func makeEditFolderViewModel(mode: EditFolderMode) -> EditFolderViewModel {
        EditFolderViewModel(
            createFolderUseCase: makeCreateFolderUseCase(),
            updateFolderUseCase: makeUpdateFolderUseCase(),
            mode: mode
        )
    }

    func makeFolderReactor(folder: Folder) -> FolderReactor {
        FolderReactor(
            folder: folder,
            fetchFolderUseCase: makeFetchFolderUseCase(),
            deleteFolderUseCase: makeDeleteFolderUseCase(),
            updateClipUseCase: makeUpdateClipUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase(),
        )
    }

    func makeHomeReactor() -> HomeReactor {
        HomeReactor(
            fetchUnvisitedClipsUseCase: makeFetchUnvisitedClipsUseCase(),
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase(),
            deleteFolderUseCase: makeDeleteFolderUseCase(),
            updateClipUseCase: makeUpdateClipUseCase()
        )
    }

    func makeUnvisitedClipListReactor(clips: [Clip]) -> UnvisitedClipListReactor {
        UnvisitedClipListReactor(
            clips: clips,
            fetchUnvisitedClipsUseCase: makeFetchUnvisitedClipsUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase(),
            updateClipUseCase: makeUpdateClipUseCase()
        )
    }

    func makeFolderSelectorViewModel(mode: FolderSelectorMode) -> FolderSelectorViewModel {
        FolderSelectorViewModel(
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            mode: mode
        )
    }
}
