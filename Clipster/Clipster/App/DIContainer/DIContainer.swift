import CoreData
import Foundation
import Supabase

final class DIContainer {
    private let container: NSPersistentContainer
    private let supabaseClient: SupabaseClient
    private let cache: FolderClipCache
    private let userDefaults: UserDefaults

    init(
        container: NSPersistentContainer? = nil,
        supabaseURL: URL,
        supabaseKey: String,
        cache: FolderClipCache,
        userDefaults: UserDefaults
    ) {
        self.container = container ?? CoreDataStack.shared.container
        supabaseClient = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
        self.cache = cache
        self.userDefaults = userDefaults
    }

    func makeClipStorage() -> ClipStorage {
        DefaultClipStorage(container: container, mapper: DomainMapper())
    }

    func makeFolderStorage() -> FolderStorage {
        DefaultFolderStorage(container: container, mapper: DomainMapper())
    }

    func makeUserService() -> UserService {
        DefaultUserService(client: supabaseClient)
    }

    func makeAuthService() -> AuthService {
        DefaultAuthService(client: supabaseClient)
    }

    func makeAppleLoginService() -> SocialLoginService {
        AppleLoginService()
    }

    func makeGoogleLoginService() -> SocialLoginService {
        GoogleLoginService()
    }

    func makeAuthRepository() -> AuthRepository {
        DefaultAuthRepository(
            socialLoginServices: [
                .apple: makeAppleLoginService(),
                .google: makeGoogleLoginService()
            ],
            authService: makeAuthService(),
            userService: makeUserService(),
            mapper: DomainMapper(),
        )
    }

    func makeClipRepository() -> ClipRepository {
        DefaultClipRepository(storage: makeClipStorage(), cache: cache)
    }

    func makeFolderRepository() -> FolderRepository {
        DefaultFolderRepository(storage: makeFolderStorage(), cache: cache)
    }

    func makeURLRepository() -> URLRepository {
        DefaultURLRepository()
    }

    func makeUserRepository() -> UserRepository {
        DefaultUserRepository(
            authService: makeAuthService(),
            userService: makeUserService(),
            mapper: DomainMapper(),
        )
    }

    func makeUserDefaultsRepository() -> UserDefaultsRepository {
        DefaultUserDefaultsRepository(userDefaults: userDefaults)
    }

    func makePasteboardRepository() -> PasteboardRepository {
        DefaultPasteboardRepository()
    }

    func makeCheckLoginStatusUseCase() -> CheckLoginStatusUseCase {
        DefaultCheckLoginStatusUseCase(authRepository: makeAuthRepository())
    }

    func makeLoginUseCase() -> LoginUseCase {
        DefaultLoginUseCase(authRepository: makeAuthRepository())
    }

    func makeLogoutUseCase() -> LogoutUseCase {
        DefaultLogoutUseCase(authRepository: makeAuthRepository())
    }

    func makeWithdrawUseCase() -> WithdrawUseCase {
        DefaultWithdrawUseCase(authRepository: makeAuthRepository())
    }

    func makeCreateClipUseCase() -> CreateClipUseCase {
        DefaultCreateClipUseCase(clipRepository: makeClipRepository())
    }

    func makeUpdateClipUseCase() -> UpdateClipUseCase {
        DefaultUpdateClipUseCase(clipRepository: makeClipRepository())
    }

    func makeVisitClipUseCase() -> VisitClipUseCase {
        DefaultVisitClipUseCase(
            clipRepository: makeClipRepository(),
            userDefaultsRepository: makeUserDefaultsRepository()
        )
    }

    func makeDeleteAllRecentVisitedClipsUseCase() -> DeleteAllRecentVisitedClipsUseCase {
        DefaultDeleteAllRecentVisitedClipsUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeDeleteClipUseCase() -> DeleteClipUseCase {
        DefaultDeleteClipUseCase(clipRepository: makeClipRepository())
    }

    func makeDeleteRecentVisitedClipUseCase() -> DeleteRecentVisitedClipUseCase {
        DefaultDeleteRecentVisitedClipUseCase(userDefaultsRepository: makeUserDefaultsRepository())
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
        DefaultFetchRecentVisitedClipsUseCase(
            clipRepository: makeClipRepository(),
            userDefaultsRepository: makeUserDefaultsRepository()
        )
    }

    func makeFetchUnvisitedClipsUseCase() -> FetchUnvisitedClipsUseCase {
        DefaultFetchUnvisitedClipsUseCase(clipRepository: makeClipRepository())
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
        DefaultDeleteAllRecentQueriesUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeDeleteRecentQueryUseCase() -> DeleteRecentQueryUseCase {
        DefaultDeleteRecentQueryUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeFetchRecentQueriesUseCase() -> FetchRecentQueriesUseCase {
        DefaultFetchRecentQueriesUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeSaveRecentQueryUseCase() -> SaveRecentQueryUseCase {
        DefaultSaveRecentQueryUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeFetchClipSortOptionUseCase() -> FetchClipSortOptionUseCase {
        DefaultFetchClipSortOptionUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeFetchFolderSortOptionUseCase() -> FetchFolderSortOptionUseCase {
        DefaultFetchFolderSortOptionUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeFetchSavePathLayoutOptionUseCase() -> FetchSavePathLayoutOptionUseCase {
        DefaultFetchSavePathLayoutOptionUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeFetchThemeOptionUseCase() -> FetchThemeOptionUseCase {
        DefaultFetchThemeOptionUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeSaveClipSortOptionUseCase() -> SaveClipSortOptionUseCase {
        DefaultSaveClipSortOptionUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeSaveFolderSortOptionUseCase() -> SaveFolderSortOptionUseCase {
        DefaultSaveFolderSortOptionUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeSaveSavePathLayoutOptionUseCase() -> SaveSavePathLayoutOptionUseCase {
        DefaultSaveSavePathLayoutOptionUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeSaveThemeOptionUseCase() -> SaveThemeOptionUseCase {
        DefaultSaveThemeOptionUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeParseURLUseCase() -> ParseURLUseCase {
        DefaultParseURLUseCase(urlMetaRepository: makeURLRepository())
    }

    func makeSanitizeURLUseCase() -> SanitizeURLUseCase {
        DefaultSanitizeURLUseCase()
    }

    func makeFetchCurrentUserUseCase() -> FetchCurrentUserUseCase {
        DefaultFetchCurrentUserUseCase(userRepository: makeUserRepository())
    }

    func makeUpdateNicknameUseCase() -> UpdateNicknameUseCase {
        DefaultUpdateNicknameUseCase(userRepository: makeUserRepository())
    }

    func makeFetchHasSeenOnboardingUseCase() -> FetchHasSeenOnboardingUseCase {
        DefaultFetchHasSeenOnboardingUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeUpdateHasSeenOnboardingUseCase() -> UpdateHasSeenOnboardingUseCase {
        DefaultUpdateHasSeenOnboardingUseCase(userDefaultsRepository: makeUserDefaultsRepository())
    }

    func makeExtractURLFromPasteboardUseCase() -> ExtractURLUseCase {
        DefaultExtractURLUseCase(pasteboardRepository: makePasteboardRepository())
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
            parseURLUseCase: makeParseURLUseCase(),
            sanitizeURLUseCase: makeSanitizeURLUseCase(),
            fetchFolderUseCase: makeFetchFolderUseCase(),
            createClipUseCase: makeCreateClipUseCase(),
            updateClipUseCase: makeUpdateClipUseCase(),
            extractURLUseCase: makeExtractURLFromPasteboardUseCase()
        )
    }

    func makeEditClipReactor(folder: Folder?) -> EditClipReactor {
        EditClipReactor(
            currentFolder: folder,
            parseURLUseCase: makeParseURLUseCase(),
            sanitizeURLUseCase: makeSanitizeURLUseCase(),
            fetchFolderUseCase: makeFetchFolderUseCase(),
            createClipUseCase: makeCreateClipUseCase(),
            updateClipUseCase: makeUpdateClipUseCase(),
            extractURLUseCase: makeExtractURLFromPasteboardUseCase()
        )
    }

    func makeEditClipReactor(clip: Clip) -> EditClipReactor {
        EditClipReactor(
            clip: clip,
            parseURLUseCase: makeParseURLUseCase(),
            sanitizeURLUseCase: makeSanitizeURLUseCase(),
            fetchFolderUseCase: makeFetchFolderUseCase(),
            createClipUseCase: makeCreateClipUseCase(),
            updateClipUseCase: makeUpdateClipUseCase(),
            extractURLUseCase: makeExtractURLFromPasteboardUseCase()
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
            fetchFolderSortOptionUseCase: makeFetchFolderSortOptionUseCase(),
            fetchClipSortOptionUseCase: makeFetchClipSortOptionUseCase(),
            sortFoldersUseCase: makeSortFoldersUseCase(),
            sortClipsUseCase: makeSortClipsUseCase(),
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
            visitClipUseCase: makeVisitClipUseCase(),
            fetchClipSortOptionUseCase: makeFetchClipSortOptionUseCase(),
            fetchFolderSortOptionUseCase: makeFetchFolderSortOptionUseCase(),
            sortClipsUseCase: makeSortClipsUseCase(),
            sortFoldersUseCase: makeSortFoldersUseCase()
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
            fetchSavePathLayoutOptionUseCase: makeFetchSavePathLayoutOptionUseCase(),
            parentFolder: parentFolder
        )
    }

    func makeFolderSelectorReactorForFolder(parentFolder: Folder?, folder: Folder?) -> FolderSelectorReactor {
        FolderSelectorReactor(
            fetchTopLevelFoldersUseCase: makeFetchTopLevelFoldersUseCase(),
            findFolderPathUseCase: makeFindFolderPathUseCase(),
            filterSubfoldersUseCase: makeFilterSubfoldersUseCase(),
            fetchSavePathLayoutOptionUseCase: makeFetchSavePathLayoutOptionUseCase(),
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
            deleteRecentQueryUseCase: makeDeleteRecentQueryUseCase(),
            deleteAllRecentQueriesUseCase: makeDeleteAllRecentQueriesUseCase(),
            deleteRecentVisitedClipUseCase: makeDeleteRecentVisitedClipUseCase(),
            deleteAllRecentVisitedClipsUseCase: makeDeleteAllRecentVisitedClipsUseCase(),
            deleteFolderUseCase: makeDeleteFolderUseCase(),
            deleteClipUseCase: makeDeleteClipUseCase(),
            searchFoldersUseCase: makeSearchFoldersUseCase(),
            searchClipsUseCase: makeSearchClipsUseCase(),
            visitClipUseCase: makeVisitClipUseCase(),
            fetchFolderSortOptionUseCase: makeFetchFolderSortOptionUseCase(),
            fetchClipSortOptionUseCase: makeFetchClipSortOptionUseCase(),
            sortFoldersUseCase: makeSortFoldersUseCase(),
            sortClipsUseCase: makeSortClipsUseCase()
        )
    }

    func makeMyPageReactor() -> MyPageReactor {
        MyPageReactor(
            checkLoginStatusUseCase: makeCheckLoginStatusUseCase(),
            loginUseCase: makeLoginUseCase(),
            fetchCurrentUserUseCase: makeFetchCurrentUserUseCase(),
            fetchThemeOptionUseCase: makeFetchThemeOptionUseCase(),
            fetchFolderSortOptionUseCase: makeFetchFolderSortOptionUseCase(),
            fetchClipSortOptionUseCase: makeFetchClipSortOptionUseCase(),
            fetchSavePathLayoutOptionUseCase: makeFetchSavePathLayoutOptionUseCase(),
            logoutUseCase: makeLogoutUseCase(),
            withdrawUseCase: makeWithdrawUseCase(),
            saveThemeOptionUseCase: makeSaveThemeOptionUseCase(),
            saveSavePathLayoutOptionUseCase: makeSaveSavePathLayoutOptionUseCase(),
            saveFolderSortOptionUseCase: makeSaveFolderSortOptionUseCase(),
            saveClipSortOptionUseCase: makeSaveClipSortOptionUseCase(),
            updateNicknameUseCase: makeUpdateNicknameUseCase()
        )
    }

    func makeDDWebReactor(url: URL) -> DDWebReactor {
        DDWebReactor(url: url)
    }
}
