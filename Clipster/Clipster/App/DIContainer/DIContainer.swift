import CoreData
import Foundation

final class DIContainer {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext? = nil) {
        self.context = context ?? CoreDataStack.shared.context
    }

    func makeClipStorage() -> ClipStorage {
         DefaultClipStorage(context: context)
     }

    func makeFolderStorage() -> FolderStorage {
         DefaultFolderStorage(context: context)
     }

    func makeClipRepository() -> ClipRepository {
        DefaultClipRepository(
            storage: makeClipStorage(),
            mapper: DomainMapper()
        )
    }

    func makeFolderRepository() -> FolderRepository {
        DefaultFolderRepository(
            storage: makeFolderStorage(),
            mapper: DomainMapper()
        )
    }

    func makeURLMetadataRepository() -> URLMetadataRepository {
        DefaultURLMetadataRepository()
    }

    func makeURLValidationRepository() -> URLValidationRepository {
        DefaultURLValidationRepository()
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

    func makeParseURLMetadataUseCase() -> ParseURLMetadataUseCase {
        DefaultParseURLMetadataUseCase(urlMetadataRepository: makeURLMetadataRepository())
    }

    func makeCheckURLValidityUseCase() -> CheckURLValidityUseCase {
        DefaultCheckValidityUseCase(urlValidationRepository: makeURLValidationRepository())
    }

    func makeClipDetailViewModel(clip: Clip, navigationTitle: String) -> ClipDetailViewModel {
        ClipDetailViewModel(
            fetchFolderUseCase: makeFetchFolderUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase(),
            fetchClipUseCase: makeFetchClipUseCase(),
            clip: clip,
            navigationTitle: navigationTitle
        )
    }

    func makeEditClipViewModel(clip: Clip) -> EditClipViewModel {
        EditClipViewModel(
            clip: clip,
            checkURLValidityUseCase: makeCheckURLValidityUseCase(),
            parseURLMetadataUseCase: makeParseURLMetadataUseCase()
        )
    }

    func makeEditFolderViewModel(mode: EditFolderMode) -> EditFolderViewModel {
        EditFolderViewModel(
            createFolderUseCase: makeCreateFolderUseCase(),
            updateFolderUseCase: makeUpdateFolderUseCase(),
            mode: mode
        )
    }

    func makeFolderViewModel(folder: Folder) -> FolderViewModel {
        FolderViewModel(
            folder: folder,
            deleteFolderUseCase: makeDeleteFolderUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase()
        )
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            fetchUnvisitedClipsUseCase: makeFetchUnvisitedClipsUseCase(),
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase(),
            deleteFolderUseCase: makeDeleteFolderUseCase()
        )
    }

    func makeUnvisitedClipListViewModel(clips: [Clip]) -> UnvisitedClipListViewModel {
        UnvisitedClipListViewModel(
            clips: clips,
            fetchUnvisitedClipsUseCase: makeFetchUnvisitedClipsUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase()
        )
    }
}
