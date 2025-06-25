import CoreData
import Foundation

final class DIContainer {
    private let container: NSPersistentContainer
    private let supabaseService: SupabaseService

    init(
        container: NSPersistentContainer? = nil,
        supabaseURL: URL,
        supabaseKey: String,
    ) {
        self.container = container ?? CoreDataStack.shared.container
        supabaseService = SupabaseService(url: supabaseURL, key: supabaseKey)
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

    func makeURLMetadataRepository() -> DefaultURLRepository {
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

    func makeCanSaveFolderUseCase() -> CanSaveFolderUseCase {
        DefaultCanSaveFolderUseCase()
    }

    func makeCanSelectFolderUseCase() -> CanSelectFolderUseCase {
        DefaultCanSelectFolderUseCase()
    }

    func makeFindFolderPathUseCase() -> FindFolderPathUseCase {
        DefaultFindFolderPathUseCase()
    }

    func makeFilterSubfoldersUseCase() -> FilterSubfoldersUseCase {
        DefaultFilterSubfoldersUseCase()
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

    func makeSanitizeFolderTitleUseCase() -> SanitizeFolderTitleUseCase {
        DefaultSanitizeFolderTitleUseCase()
    }

    func makeUpdateFolderUseCase() -> UpdateFolderUseCase {
        DefaultUpdateFolderUseCase(folderRepository: makeFolderRepository())
    }

    func makeParseURLMetadataUseCase() -> ParseURLUseCase {
        DefaultParseURLUseCase(urlMetaRepository: makeURLMetadataRepository())
    }

    func makeClipDetailReactor(clip: Clip) -> ClipDetailReactor {
        ClipDetailReactor(
            fetchFolderUseCase: makeFetchFolderUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase(),
            fetchClipUseCase: makeFetchClipUseCase(),
            clip: clip,
        )
    }

    func makeEditClipReactor() -> EditClipReactor {
        EditClipReactor(
            parseURLUseCase: makeParseURLMetadataUseCase(),
            fetchFolderUseCase: makeFetchFolderUseCase(),
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            createClipUseCase: makeCreateClipUseCase(),
            updateClipUseCase: makeUpdateClipUseCase()
        )
    }

    func makeEditClipReactor(urlString: String) -> EditClipReactor {
        EditClipReactor(
            urlText: urlString,
            parseURLUseCase: makeParseURLMetadataUseCase(),
            fetchFolderUseCase: makeFetchFolderUseCase(),
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            createClipUseCase: makeCreateClipUseCase(),
            updateClipUseCase: makeUpdateClipUseCase()
        )
    }

    func makeEditClipReactor(folder: Folder?) -> EditClipReactor {
        EditClipReactor(
            currentFolder: folder,
            parseURLUseCase: makeParseURLMetadataUseCase(),
            fetchFolderUseCase: makeFetchFolderUseCase(),
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            createClipUseCase: makeCreateClipUseCase(),
            updateClipUseCase: makeUpdateClipUseCase()
        )
    }

    func makeEditClipReactor(clip: Clip) -> EditClipReactor {
        EditClipReactor(
            clip: clip,
            parseURLUseCase: makeParseURLMetadataUseCase(),
            fetchFolderUseCase: makeFetchFolderUseCase(),
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            createClipUseCase: makeCreateClipUseCase(),
            updateClipUseCase: makeUpdateClipUseCase()
        )
    }

    func makeEditFolderReactor(parentFolder: Folder?, folder: Folder?) -> EditFolderReactor {
        EditFolderReactor(
            canSaveFolderUseCase: makeCanSaveFolderUseCase(),
            sanitizeFolderTitleUseCase: makeSanitizeFolderTitleUseCase(),
            createFolderUseCase: makeCreateFolderUseCase(),
            updateFolderUseCase: makeUpdateFolderUseCase(),
            parentFolder: parentFolder,
            folder: folder
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

    func makeFolderSelectorReactorForClip(parentFolder: Folder?) -> FolderSelectorReactor {
        FolderSelectorReactor(
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            canSelectFolderUseCase: makeCanSelectFolderUseCase(),
            findFolderPathUseCase: makeFindFolderPathUseCase(),
            filterSubfoldersUseCase: makeFilterSubfoldersUseCase(),
            parentFolder: parentFolder
        )
    }

    func makeFolderSelectorReactorForFolder(parentFolder: Folder?, folder: Folder?) -> FolderSelectorReactor {
        FolderSelectorReactor(
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            canSelectFolderUseCase: makeCanSelectFolderUseCase(),
            findFolderPathUseCase: makeFindFolderPathUseCase(),
            filterSubfoldersUseCase: makeFilterSubfoldersUseCase(),
            parentFolder: parentFolder,
            folder: folder
        )
    }
}
