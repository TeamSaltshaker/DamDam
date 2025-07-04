import CoreData
import Foundation

final class ShareDIContainer {
    private let container: NSPersistentContainer

    init() {
        self.container = CoreDataStack.shared.container
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

    func makeExtractExtensionContextUseCase() -> ExtractExtensionContextUseCase {
        DefaultExtractExtensionContextUseCase()
    }

    func makeShareReactor() -> ShareReactor {
        ShareReactor(
            parseURLUseCase: makeParseURLUseCase(),
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
        DefaultFetchSavePathLayoutOptionUseCase()
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
