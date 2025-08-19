import CoreData
import Foundation

final class ShareDIContainer {
    private let appGroupID: String = {
        #if DEBUG
        return "group.com.saltshaker.clipster.debug"
        #else
        return "group.com.saltshaker.clipster"
        #endif
    }()

    private let container: NSPersistentContainer
    private let userDefaults: UserDefaults

    init() {
        self.container = CoreDataStack.shared.container
        self.userDefaults = UserDefaults(suiteName: appGroupID) ?? .standard
    }

    func makeClipStorage() -> ClipStorage {
        DefaultClipStorage(container: container, mapper: DomainMapper())
    }

    func makeURLRepository() -> URLRepository {
        DefaultURLRepository()
    }

    func makeClipRepository() -> ClipRepository {
        DefaultClipRepository(storage: makeClipStorage(), cache: nil)
    }

    func makeCreateClipUseCase() -> CreateClipUseCase {
        DefaultCreateClipUseCase(clipRepository: makeClipRepository())
    }

    func makeParseURLUseCase() -> ParseURLUseCase {
        DefaultParseURLUseCase(urlMetaRepository: makeURLRepository())
    }

    func makeSanitizeURLUseCase() -> SanitizeURLUseCase {
        DefaultSanitizeURLUseCase()
    }

    func makeExtractExtensionContextUseCase() -> ExtractExtensionContextUseCase {
        DefaultExtractExtensionContextUseCase()
    }

    func makeShareReactor() -> ShareReactor {
        ShareReactor(
            parseURLUseCase: makeParseURLUseCase(),
            sanitizeURLUseCase: makeSanitizeURLUseCase(),
            createClipUseCase: makeCreateClipUseCase(),
            extractExtensionContextUseCase: makeExtractExtensionContextUseCase()
        )
    }

    func makeFolderStorage() -> FolderStorage {
        DefaultFolderStorage(container: container, mapper: DomainMapper())
    }

    func makeFolderRepository() -> FolderRepository {
        DefaultFolderRepository(storage: makeFolderStorage(), cache: nil)
    }

    func makeUserDefaultsRepository() -> UserDefaultsRepository {
        DefaultUserDefaultsRepository(userDefaults: userDefaults)
    }

    func makeFetchTopLevelFoldersUseCase() -> FetchTopLevelFoldersUseCase {
        DefaultFetchTopLevelFoldersUseCase(folderRepository: makeFolderRepository())
    }

    func makeFindFolderPathUseCase() -> FindFolderPathUseCase {
        DefaultFindFolderPathUseCase()
    }

    func makeFilterSubfoldersUseCase() -> FilterSubfoldersUseCase {
        DefaultFilterSubfoldersUseCase()
    }

    func makeFetchSavePathLayoutOptionUseCase() -> FetchSavePathLayoutOptionUseCase {
        DefaultFetchSavePathLayoutOptionUseCase(userDefaultsRepository: makeUserDefaultsRepository())
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
}
