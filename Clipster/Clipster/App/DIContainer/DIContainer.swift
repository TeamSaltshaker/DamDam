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

    func makeAppleLoginService() -> SocialLoginService {
        AppleLoginService()
    }

    func makeGoogleLoginService() -> SocialLoginService {
        GoogleLoginService()
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

    func makeLoginUseCase() -> LoginUseCase {
        DefaultLoginUseCase(loginServices: [
            .apple: makeAppleLoginService(),
            .google: makeGoogleLoginService()
        ])
    }

    func makeCreateClipUseCase() -> CreateClipUseCase {
        DefaultCreateClipUseCase(clipRepository: makeClipRepository())
    }

    func makeUpdateClipUseCase() -> UpdateClipUseCase {
        DefaultUpdateClipUseCase(clipRepository: makeClipRepository())
    }

    func makeVisitClipUseCase() -> VisitClipUseCase {
        DefaultVisitClipUseCase(clipRepository: makeClipRepository())
    }

    func makeDeleteAllRecentVisitedClipsUseCase() -> DeleteAllRecentVisitedClipsUseCase {
        DefaultDeleteAllRecentVisitedClipsUseCase()
    }

    func makeDeleteClipUseCase() -> DeleteClipUseCase {
        DefaultDeleteClipUseCase(clipRepository: makeClipRepository())
    }

    func makeDeleteRecentVisitedClipUseCase() -> DeleteRecentVisitedClipUseCase {
        DefaultDeleteRecentVisitedClipUseCase()
    }

    func makeFetchAllClipsUseCase() -> FetchAllClipsUseCase {
        DefaultFetchAllClipsUseCase(clipRepository: makeClipRepository())
    }

    func makeFetchClipUseCase() -> FetchClipUseCase {
        DefaultFetchClipUseCase(clipRepository: makeClipRepository())
    }

    func makeFetchTopLevelClipsUseCase() -> FetchTopLevelClipsUseCase {
        DefaultFetchTopLevelClipsUseCase(clipRepository: makeClipRepository())
    }

    func makeFetchRecentVisitedClipsUseCase() -> FetchRecentVisitedClipsUseCase {
        DefaultFetchRecentVisitedClipsUseCase(clipRepository: makeClipRepository())
    }

    func makeFetchUnvisitedClipsUseCase() -> FetchUnvisitedClipsUseCase {
        DefaultFetchUnvisitedClipsUseCase(clipRepository: makeClipRepository())
    }

    func makeSaveRecentVisitedClipUseCase() -> SaveRecentVisitedClipUseCase {
        DefaultSaveRecentVisitedClipUseCase()
    }

    func makeSearchClipsUseCase() -> SearchClipsUseCase {
        DefaultSearchClipsUseCase()
    }

    func makeSortClipsUseCase() -> SortClipsUseCase {
        DefaultSortClipsUseCase()
    }

    func makeCanSaveFolderUseCase() -> CanSaveFolderUseCase {
        DefaultCanSaveFolderUseCase()
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

    func makeFetchAllFoldersUseCase() -> FetchAllFoldersUseCase {
        DefaultFetchAllFoldersUseCase(folderRepository: makeFolderRepository())
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

    func makeSearchFoldersUseCase() -> SearchFoldersUseCase {
        DefaultSearchFoldersUseCase()
    }

    func makeSortFoldersUseCase() -> SortFoldersUseCase {
        DefaultSortFoldersUseCase()
    }

    func makeUpdateFolderUseCase() -> UpdateFolderUseCase {
        DefaultUpdateFolderUseCase(folderRepository: makeFolderRepository())
    }

    func makeDeleteAllRecentQueriesUseCase() -> DeleteAllRecentQueriesUseCase {
        DefaultDeleteAllRecentQueriesUseCase()
    }

    func makeDeleteRecentQueryUseCase() -> DeleteRecentQueryUseCase {
        DefaultDeleteRecentQueryUseCase()
    }

    func makeFetchRecentQueriesUseCase() -> FetchRecentQueriesUseCase {
        DefaultFetchRecentQueriesUseCase()
    }

    func makeSaveRecentQueryUseCase() -> SaveRecentQueryUseCase {
        DefaultSaveRecentQueryUseCase()
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
            visitClipUseCase: makeVisitClipUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase(),
        )
    }

    func makeHomeReactor() -> HomeReactor {
        HomeReactor(
            fetchUnvisitedClipsUseCase: makeFetchUnvisitedClipsUseCase(),
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            fetchTopLevelClipsUseCase: makeFetchTopLevelClipsUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase(),
            deleteFolderUseCase: makeDeleteFolderUseCase(),
            visitClipUseCase: makeVisitClipUseCase()
        )
    }

    func makeUnvisitedClipListReactor(clips: [Clip]) -> UnvisitedClipListReactor {
        UnvisitedClipListReactor(
            clips: clips,
            fetchUnvisitedClipsUseCase: makeFetchUnvisitedClipsUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase(),
            visitClipUseCase: makeVisitClipUseCase()
        )
    }

    func makeFolderSelectorReactorForClip(parentFolder: Folder?) -> FolderSelectorReactor {
        FolderSelectorReactor(
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            findFolderPathUseCase: makeFindFolderPathUseCase(),
            filterSubfoldersUseCase: makeFilterSubfoldersUseCase(),
            parentFolder: parentFolder
        )
    }

    func makeFolderSelectorReactorForFolder(parentFolder: Folder?, folder: Folder?) -> FolderSelectorReactor {
        FolderSelectorReactor(
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            findFolderPathUseCase: makeFindFolderPathUseCase(),
            filterSubfoldersUseCase: makeFilterSubfoldersUseCase(),
            parentFolder: parentFolder,
            folder: folder
        )
    }

    func makeSearchReactor() -> SearchReactor {
        SearchReactor(
            fetchAllFoldersUseCase: makeFetchAllFoldersUseCase(),
            fetchAllClipsUseCase: makeFetchAllClipsUseCase(),
            fetchRecentQueriesUseCase: makeFetchRecentQueriesUseCase(),
            fetchRecentVisitedClipsUseCase: makeFetchRecentVisitedClipsUseCase(),
            saveRecentQueryUseCase: makeSaveRecentQueryUseCase(),
            saveRecentVisitedClipUseCase: makeSaveRecentVisitedClipUseCase(),
            deleteRecentQueryUseCase: makeDeleteRecentQueryUseCase(),
            deleteAllRecentQueriesUseCase: makeDeleteAllRecentQueriesUseCase(),
            deleteRecentVisitedClipUseCase: makeDeleteRecentVisitedClipUseCase(),
            deleteAllRecentVisitedClipsUseCase: makeDeleteAllRecentVisitedClipsUseCase(),
            deleteFolderUseCase: makeDeleteFolderUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase(),
            searchFoldersUseCase: makeSearchFoldersUseCase(),
            searchClipsUseCase: makeSearchClipsUseCase(),
            visitClipUseCase: makeVisitClipUseCase()
        )
    }
}
