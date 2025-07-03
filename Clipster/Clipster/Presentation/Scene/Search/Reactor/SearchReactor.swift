import Foundation
import ReactorKit
import RxSwift

final class SearchReactor: Reactor {
    enum SearchSection: Hashable {
        case recentQueries(headerTitle: String)
        case recentVisitedClips(headerTitle: String)
        case folderResults(headerTitle: String, count: Int)
        case clipResults(headerTitle: String, count: Int)

        var title: String {
            switch self {
            case .recentQueries(let headerTitle),
                 .recentVisitedClips(let headerTitle),
                 .folderResults(let headerTitle, _),
                 .clipResults(let headerTitle, _):
                return headerTitle
            }
        }
    }

    enum SearchItem: Hashable {
        case recentQuery(String)
        case recentVisitedClip(ClipDisplay)
        case folder(folder: FolderDisplay, query: String)
        case clip(clip: ClipDisplay, query: String)

        var title: String {
            switch self {
            case .recentQuery(let query):
                return query
            case .recentVisitedClip(let clipDisplay):
                return clipDisplay.urlMetadata.title
            case .folder(let folderDisplay, _):
                return folderDisplay.title
            case .clip(let clipDisplay, _):
                return clipDisplay.urlMetadata.title
            }
        }
    }

    struct SearchSectionModel: Hashable {
        var section: SearchSection
        var items: [SearchItem]
    }

    enum Action {
        case viewDidLoad
        case updateQuery(String)
        case endEditingQuery
        case clearButtonTapped
        case deleteRecentQueryTapped(String)
        case deleteAllRecentQueriesTapped
        case deleteRecentVisitedClipTapped(ClipDisplay)
        case deleteAllRecentVisitedClipsTapped
        case itemTapped(SearchItem)
        case editTapped(SearchItem)
        case detailTapped(SearchItem)
        case deleteTapped(SearchItem)
    }

    enum Mutation {
        case setQuery(String)
        case setSections([SearchSectionModel])
        case deleteRecentQuery(String)
        case deleteAllRecentQueries
        case deleteRecentVisitedClip(ClipDisplay)
        case deleteAllRecentVisitedClips
        case deleteFolder(Folder)
        case deleteClip(Clip)
        case setPhase(State.Phase)
        case setRoute(State.Route?)
    }

    struct State {
        var query: String = ""
        var sections: [SearchSectionModel] = []

        @Pulse var phase: Phase = .idle
        @Pulse var route: Route?

        enum Phase {
            case idle
            case loading
            case success
            case error(String)
        }

        enum Route {
            case showWebView(URL)
            case showFolderView(Folder)
            case showEditFolder(parent: Folder?, folder: Folder)
            case showEditClip(Clip)
            case showDetailClip(Clip)
        }

        var shouldShowNoResultsView: Bool {
            !query.isEmpty && sections.isEmpty
        }
    }

    let initialState = State()

    private let fetchAllFoldersUseCase: FetchAllFoldersUseCase
    private let fetchAllClipsUseCase: FetchAllClipsUseCase
    private let fetchRecentQueriesUseCase: FetchRecentQueriesUseCase
    private let fetchRecentVisitedClipsUseCase: FetchRecentVisitedClipsUseCase
    private let saveRecentQueryUseCase: SaveRecentQueryUseCase
    private let saveRecentVisitedClipUseCase: SaveRecentVisitedClipUseCase
    private let deleteRecentQueryUseCase: DeleteRecentQueryUseCase
    private let deleteAllRecentQueriesUseCase: DeleteAllRecentQueriesUseCase
    private let deleteRecentVisitedClipUseCase: DeleteRecentVisitedClipUseCase
    private let deleteAllRecentVisitedClipsUseCase: DeleteAllRecentVisitedClipsUseCase
    private let deleteFolderUseCase: DeleteFolderUseCase
    private let deleteClipUseCase: DeleteClipUseCase
    private let searchFoldersUseCase: SearchFoldersUseCase
    private let searchClipsUseCase: SearchClipsUseCase
    private let visitClipUseCase: VisitClipUseCase

    private var allFolders: [Folder] = []
    private var allClips: [Clip] = []

    init(
        fetchAllFoldersUseCase: FetchAllFoldersUseCase,
        fetchAllClipsUseCase: FetchAllClipsUseCase,
        fetchRecentQueriesUseCase: FetchRecentQueriesUseCase,
        fetchRecentVisitedClipsUseCase: FetchRecentVisitedClipsUseCase,
        saveRecentQueryUseCase: SaveRecentQueryUseCase,
        saveRecentVisitedClipUseCase: SaveRecentVisitedClipUseCase,
        deleteRecentQueryUseCase: DeleteRecentQueryUseCase,
        deleteAllRecentQueriesUseCase: DeleteAllRecentQueriesUseCase,
        deleteRecentVisitedClipUseCase: DeleteRecentVisitedClipUseCase,
        deleteAllRecentVisitedClipsUseCase: DeleteAllRecentVisitedClipsUseCase,
        deleteFolderUseCase: DeleteFolderUseCase,
        deleteClipUseCase: DeleteClipUseCase,
        searchFoldersUseCase: SearchFoldersUseCase,
        searchClipsUseCase: SearchClipsUseCase,
        visitClipUseCase: VisitClipUseCase
    ) {
        self.fetchAllFoldersUseCase = fetchAllFoldersUseCase
        self.fetchAllClipsUseCase = fetchAllClipsUseCase
        self.fetchRecentQueriesUseCase = fetchRecentQueriesUseCase
        self.fetchRecentVisitedClipsUseCase = fetchRecentVisitedClipsUseCase
        self.saveRecentQueryUseCase = saveRecentQueryUseCase
        self.saveRecentVisitedClipUseCase = saveRecentVisitedClipUseCase
        self.deleteRecentQueryUseCase = deleteRecentQueryUseCase
        self.deleteAllRecentQueriesUseCase = deleteAllRecentQueriesUseCase
        self.deleteRecentVisitedClipUseCase = deleteRecentVisitedClipUseCase
        self.deleteAllRecentVisitedClipsUseCase = deleteAllRecentVisitedClipsUseCase
        self.deleteFolderUseCase = deleteFolderUseCase
        self.deleteClipUseCase = deleteClipUseCase
        self.searchFoldersUseCase = searchFoldersUseCase
        self.searchClipsUseCase = searchClipsUseCase
        self.visitClipUseCase = visitClipUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return prepareData()
        case .updateQuery(let query):
            let setQuery = Observable.just(Mutation.setQuery(query))
            let searchOrLoadInitial = Observable.just(query)
                .flatMap { [weak self] query -> Observable<Mutation> in
                    guard let self else { return .empty() }

                    if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        return prepareData()
                    } else {
                        return .just(executeSearch(with: query))
                    }
                }
            return .merge(setQuery, searchOrLoadInitial)
        case .endEditingQuery:
            let query = currentState.query
            guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return .empty()
            }
            return .fromAsync { [weak self] in
                self?.saveRecentQueryUseCase.execute(query)
            }
            .flatMap { _ in Observable.empty() }
            .catch { _ in .empty() }
        case .clearButtonTapped:
            return .concat(
                .just(.setQuery("")),
                self.prepareData()
            )
        case .deleteRecentQueryTapped(let query):
            return .concat(
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    self?.deleteRecentQueryUseCase.execute(query)
                    return .deleteRecentQuery(query)
                }
                .catch { .just(.setPhase(.error($0.localizedDescription))) },
                .just(.setPhase(.idle))
            )
        case .deleteAllRecentQueriesTapped:
            return .concat(
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    self?.deleteAllRecentQueriesUseCase.execute()
                    return .deleteAllRecentQueries
                }
                .catch { .just(.setPhase(.error($0.localizedDescription))) },
                .just(.setPhase(.idle))
            )
        case .deleteRecentVisitedClipTapped(let clip):
            return .concat(
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    self?.deleteRecentVisitedClipUseCase.execute(clip.id.uuidString)
                    return .deleteRecentVisitedClip(clip)
                }
                .catch { .just(.setPhase(.error($0.localizedDescription))) },
                .just(.setPhase(.idle))
            )
        case .deleteAllRecentVisitedClipsTapped:
            return .concat(
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    self?.deleteAllRecentVisitedClipsUseCase.execute()
                    return .deleteAllRecentVisitedClips
                }
                .catch { .just(.setPhase(.error($0.localizedDescription))) },
                .just(.setPhase(.idle))
            )
        case .itemTapped(let item):
            switch item {
            case .recentQuery(let query):
                return .concat(
                    .just(.setQuery(query)),
                    .just(executeSearch(with: query))
                )
            case .recentVisitedClip(let clipDisplay), .clip(let clipDisplay, _):
                guard let clip = self.allClips.first(where: { $0.id == clipDisplay.id }) else {
                    return .empty()
                }

                return .fromAsync { [weak self] in
                    _ = try await self?.saveRecentVisitedClipUseCase.execute(clip.id).get()
                    _ = try await self?.visitClipUseCase.execute(clip: clip).get()
                    return .setRoute(.showWebView(clip.url))
                }
                .catch { _ in .empty() }
            case .folder(let folderDisplay, _):
                if let folder = self.allFolders.first(where: { $0.id == folderDisplay.id }) {
                    return .just(.setRoute(.showFolderView(folder)))
                }
                return .empty()
            }
        case .editTapped(let item):
            switch item {
            case .folder(let folderDisplay, _):
                if let folder = self.allFolders.first(where: { $0.id == folderDisplay.id }) {
                    let parent = self.allFolders.first { $0.id == folder.parentFolderID }
                    return .just(.setRoute(.showEditFolder(parent: parent, folder: folder)))
                }
            case .clip(let clipDisplay, _):
                if let clip = self.allClips.first(where: { $0.id == clipDisplay.id }) {
                    return .just(.setRoute(.showEditClip(clip)))
                }
            default: break
            }
            return .empty()
        case .detailTapped(let item):
            switch item {
            case .clip(let clipDisplay, _):
                if let clip = self.allClips.first(where: { $0.id == clipDisplay.id }) {
                    return .just(.setRoute(.showDetailClip(clip)))
                }
            default: break
            }
            return .empty()
        case .deleteTapped(let item):
            switch item {
            case .folder(let folderDisplay, _):
                guard let folder = self.allFolders.first(where: { $0.id == folderDisplay.id }) else {
                    return .empty()
                }

                return .concat(
                    .just(.setPhase(.loading)),
                    .fromAsync { [weak self] in
                        guard let self else { throw DomainError.unknownError }
                        _ = try await deleteFolderUseCase.execute(folder).get()
                        return .deleteFolder(folder)
                    }
                    .catch { .just(.setPhase(.error($0.localizedDescription))) },
                    .just(.setPhase(.idle))
                )
            case .clip(let clipDisplay, _):
                guard let clip = self.allClips.first(where: { $0.id == clipDisplay.id }) else {
                    return .empty()
                }

                return .concat(
                    .just(.setPhase(.loading)),
                    .fromAsync { [weak self] in
                        guard let self else { throw DomainError.unknownError }
                        _ = try await deleteClipUseCase.execute(clip).get()
                        return .deleteClip(clip)
                    }
                    .catch { .just(.setPhase(.error($0.localizedDescription))) },
                    .just(.setPhase(.idle))
                )
            default: break
            }
            return .empty()
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.route = nil

        switch mutation {
        case .setSections(let sections):
            newState.sections = sections
        case .setQuery(let query):
            newState.query = query
        case .deleteRecentQuery(let query):
            guard let index = newState.sections.firstIndex(where: {
                if case .recentQueries = $0.section {
                    return true
                }
                return false
            }) else {
                return newState
            }
            newState.sections[index].items.removeAll {
                if case .recentQuery(let q) = $0 { return q == query }
                return false
            }
            if newState.sections[index].items.isEmpty {
                newState.sections.remove(at: index)
            }
        case .deleteAllRecentQueries:
            newState.sections.removeAll { model in
                if case .recentQueries = model.section {
                    return true
                }
                return false
            }
        case .deleteRecentVisitedClip(let clip):
            guard let index = newState.sections.firstIndex(where: {
                if case .recentVisitedClips = $0.section {
                    return true
                }
                return false
            }) else {
                return newState
            }
            newState.sections[index].items.removeAll {
                if case .clip(let clipDisplay, _) = $0 { return clipDisplay.id == clip.id }
                return false
            }
            if newState.sections[index].items.isEmpty {
                newState.sections.remove(at: index)
            }

        case .deleteAllRecentVisitedClips:
            newState.sections.removeAll { model in
                if case .recentVisitedClips = model.section {
                    return true
                }
                return false
            }
        case .deleteFolder(let deletedFolder):
            allFolders.removeAll { $0.id == deletedFolder.id }
            newState.sections.indices.forEach { index in
                newState.sections[index].items.removeAll {
                    if case .folder(let folderDisplay, _) = $0 { return folderDisplay.id == deletedFolder.id }
                    return false
                }
            }

        case .deleteClip(let deletedClip):
            allClips.removeAll { $0.id == deletedClip.id }
            newState.sections.indices.forEach { index in
                newState.sections[index].items.removeAll {
                    if case .clip(let clipDisplay, _) = $0 { return clipDisplay.id == deletedClip.id }
                    return false
                }
            }
        case .setPhase(let phase):
            newState.phase = phase
        case .setRoute(let route):
            newState.route = route
        }
        return newState
    }
}

private extension SearchReactor {
    private func prepareData() -> Observable<Mutation> {
        .fromAsync { [weak self] in
            guard let self else { throw DomainError.unknownError }

            let folders = try await self.fetchAllFoldersUseCase.execute().get()
            let clips = try await self.fetchAllClipsUseCase.execute().get()
            let recentQueries = self.fetchRecentQueriesUseCase.execute()
            let recentVisitedClips = try await self.fetchRecentVisitedClipsUseCase.execute().get()

            self.allFolders = folders
            self.allClips = clips

            return (recentQueries, recentVisitedClips)
        }
        .map { recentQueries, recentVisitedClips in
            var sections: [SearchSectionModel] = []
            if !recentQueries.isEmpty {
                sections.append(.init(section: .recentQueries(headerTitle: "최근 검색어"), items: recentQueries.map { .recentQuery($0) }))
            }
            if !recentVisitedClips.isEmpty {
                sections.append(.init(section: .recentVisitedClips(headerTitle: "최근 방문클립"), items: recentVisitedClips.map { .recentVisitedClip(ClipDisplayMapper.map($0)) }))
            }
            return .setSections(sections)
        }
        .catch { _ in .just(.setSections([])) }
    }

    private func executeSearch(with query: String) -> Mutation {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        let filteredFolders = self.searchFoldersUseCase.execute(query: trimmedQuery, in: self.allFolders)
        let filteredClips = self.searchClipsUseCase.execute(query: trimmedQuery, in: self.allClips)

        let folderItems = filteredFolders.map { SearchItem.folder(folder: FolderDisplayMapper.map($0), query: query) }
        let clipItems = filteredClips.map { SearchItem.clip(clip: ClipDisplayMapper.map($0), query: query) }

        var sections: [SearchSectionModel] = []
        if !folderItems.isEmpty {
            sections.append(.init(section: .folderResults(headerTitle: "폴더", count: folderItems.count), items: folderItems))
        }
        if !clipItems.isEmpty {
            sections.append(.init(section: .clipResults(headerTitle: "클립", count: clipItems.count), items: clipItems))
        }

        return .setSections(sections)
    }
}
