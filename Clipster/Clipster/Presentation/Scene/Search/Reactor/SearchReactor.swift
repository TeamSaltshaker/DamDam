import Foundation
import ReactorKit
import RxSwift

final class SearchReactor: Reactor {
    enum SearchSection: Hashable {
        case recentQueries(headerTitle: String)
        case recentVisitedClips(headerTitle: String)
        case folderResults(headerTitle: String)
        case clipResults(headerTitle: String)

        var title: String {
            switch self {
            case .recentQueries(let headerTitle),
                 .recentVisitedClips(let headerTitle),
                 .folderResults(let headerTitle),
                 .clipResults(let headerTitle):
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
        case viewWillAppear
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
    private let deleteRecentQueryUseCase: DeleteRecentQueryUseCase
    private let deleteAllRecentQueriesUseCase: DeleteAllRecentQueriesUseCase
    private let deleteRecentVisitedClipUseCase: DeleteRecentVisitedClipUseCase
    private let deleteAllRecentVisitedClipsUseCase: DeleteAllRecentVisitedClipsUseCase
    private let deleteFolderUseCase: DeleteFolderUseCase
    private let deleteClipUseCase: DeleteClipUseCase
    private let searchFoldersUseCase: SearchFoldersUseCase
    private let searchClipsUseCase: SearchClipsUseCase
    private let visitClipUseCase: VisitClipUseCase
    private let fetchFolderSortOptionUseCase: FetchFolderSortOptionUseCase
    private let fetchClipSortOptionUseCase: FetchClipSortOptionUseCase
    private let sortFoldersUseCase: SortFoldersUseCase
    private let sortClipsUseCase: SortClipsUseCase

    private var allFolders: [Folder] = []
    private var allClips: [Clip] = []
    private var folderSortOption: FolderSortOption = .createdAt(.ascending)
    private var clipSortOption: ClipSortOption = .createdAt(.descending)

    init(
        fetchAllFoldersUseCase: FetchAllFoldersUseCase,
        fetchAllClipsUseCase: FetchAllClipsUseCase,
        fetchRecentQueriesUseCase: FetchRecentQueriesUseCase,
        fetchRecentVisitedClipsUseCase: FetchRecentVisitedClipsUseCase,
        saveRecentQueryUseCase: SaveRecentQueryUseCase,
        deleteRecentQueryUseCase: DeleteRecentQueryUseCase,
        deleteAllRecentQueriesUseCase: DeleteAllRecentQueriesUseCase,
        deleteRecentVisitedClipUseCase: DeleteRecentVisitedClipUseCase,
        deleteAllRecentVisitedClipsUseCase: DeleteAllRecentVisitedClipsUseCase,
        deleteFolderUseCase: DeleteFolderUseCase,
        deleteClipUseCase: DeleteClipUseCase,
        searchFoldersUseCase: SearchFoldersUseCase,
        searchClipsUseCase: SearchClipsUseCase,
        visitClipUseCase: VisitClipUseCase,
        fetchFolderSortOptionUseCase: FetchFolderSortOptionUseCase,
        fetchClipSortOptionUseCase: FetchClipSortOptionUseCase,
        sortFoldersUseCase: SortFoldersUseCase,
        sortClipsUseCase: SortClipsUseCase,
    ) {
        self.fetchAllFoldersUseCase = fetchAllFoldersUseCase
        self.fetchAllClipsUseCase = fetchAllClipsUseCase
        self.fetchRecentQueriesUseCase = fetchRecentQueriesUseCase
        self.fetchRecentVisitedClipsUseCase = fetchRecentVisitedClipsUseCase
        self.saveRecentQueryUseCase = saveRecentQueryUseCase
        self.deleteRecentQueryUseCase = deleteRecentQueryUseCase
        self.deleteAllRecentQueriesUseCase = deleteAllRecentQueriesUseCase
        self.deleteRecentVisitedClipUseCase = deleteRecentVisitedClipUseCase
        self.deleteAllRecentVisitedClipsUseCase = deleteAllRecentVisitedClipsUseCase
        self.deleteFolderUseCase = deleteFolderUseCase
        self.deleteClipUseCase = deleteClipUseCase
        self.searchFoldersUseCase = searchFoldersUseCase
        self.searchClipsUseCase = searchClipsUseCase
        self.visitClipUseCase = visitClipUseCase
        self.fetchFolderSortOptionUseCase = fetchFolderSortOptionUseCase
        self.fetchClipSortOptionUseCase = fetchClipSortOptionUseCase
        self.sortFoldersUseCase = sortFoldersUseCase
        self.sortClipsUseCase = sortClipsUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            let query = currentState.query
            if query.isEmpty {
                return prepareData()
            } else {
                return .concat(
                    .fromAsync { [weak self] in
                        guard let self else { return }
                        allFolders = try await fetchAllFoldersUseCase.execute().get()
                        allClips = try await fetchAllClipsUseCase.execute().get()
                        folderSortOption = try await fetchFolderSortOptionUseCase.execute().get()
                        clipSortOption = try await fetchClipSortOptionUseCase.execute().get()
                    }
                    .flatMap { _ -> Observable<Mutation> in .empty() }
                    .catch { .just(.setPhase(.error($0.localizedDescription))) },
                    .just(self.executeSearch(with: query))
                )
            }
        case .updateQuery(let query):
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            let setQuery = Observable.just(Mutation.setQuery(trimmedQuery))
            let searchOrLoadInitial = Observable.just(trimmedQuery)
                .flatMap { [weak self] trimmedQuery -> Observable<Mutation> in
                    guard let self else { return .empty() }

                    if trimmedQuery.isEmpty {
                        return prepareData()
                    } else {
                        return .just(executeSearch(with: trimmedQuery))
                    }
                }
            return .merge(setQuery, searchOrLoadInitial)
        case .endEditingQuery:
            let query = currentState.query
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedQuery.isEmpty else {
                return .empty()
            }
            saveRecentQueryUseCase.execute(trimmedQuery)
            return .empty()
        case .clearButtonTapped:
            return .concat(
                .just(.setQuery("")),
                self.prepareData()
            )
        case .deleteRecentQueryTapped(let query):
            deleteRecentQueryUseCase.execute(query)
            return .just(.deleteRecentQuery(query))
        case .deleteAllRecentQueriesTapped:
            deleteAllRecentQueriesUseCase.execute()
            return .just(.deleteAllRecentQueries)
        case .deleteRecentVisitedClipTapped(let clip):
            deleteRecentVisitedClipUseCase.execute(clip.id.uuidString)
            return .just(.deleteRecentVisitedClip(clip))
        case .deleteAllRecentVisitedClipsTapped:
            deleteAllRecentVisitedClipsUseCase.execute()
            return .just(.deleteAllRecentVisitedClips)
        case .itemTapped(let item):
            switch item {
            case .recentQuery(let query):
                let saveQuery = Observable<Mutation>.fromAsync { [weak self] in
                    self?.saveRecentQueryUseCase.execute(query)
                }
                .flatMap { Observable<Mutation>.empty() }
                .catch { _ in Observable<Mutation>.empty() }

                let update = Observable.concat(
                    .just(Mutation.setQuery(query)),
                    .just(executeSearch(with: query))
                )
                return .merge(saveQuery, update)
            case .recentVisitedClip(let clipDisplay), .clip(let clipDisplay, _):
                guard let clip = self.allClips.first(where: { $0.id == clipDisplay.id }) else {
                    return .empty()
                }

                return .fromAsync { [weak self] in
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
                        allFolders.removeAll { $0.id == folder.id }
                        return .deleteFolder(folder)
                    }
                    .catch { .just(.setPhase(.error($0.localizedDescription))) },
                    .just(.setPhase(.idle))
                )
            case .clip(let clipDisplay, _):
                guard let clip = allClips.first(where: { $0.id == clipDisplay.id }) else {
                    return .empty()
                }
                return .concat(
                    .just(.setPhase(.loading)),
                    .fromAsync { [weak self] in
                        guard let self else { throw DomainError.unknownError }
                        _ = try await deleteClipUseCase.execute(clip).get()
                        allClips.removeAll { $0.id == clip.id }
                        return .deleteClip(clip)
                    }
                    .catch { .just(.setPhase(.error($0.localizedDescription))) },
                    .just(.setPhase(.idle))
                )
            default:
                return .empty()
            }
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
                if case .recentVisitedClip(let clipDisplay) = $0 { return clipDisplay.id == clip.id }
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
            newState.sections.indices.forEach { index in
                newState.sections[index].items.removeAll {
                    if case .folder(let folderDisplay, _) = $0 { return folderDisplay.id == deletedFolder.id }
                    return false
                }
            }
            newState.sections.removeAll { $0.items.isEmpty }
        case .deleteClip(let deletedClip):
            newState.sections.indices.forEach { index in
                newState.sections[index].items.removeAll {
                    if case .clip(let clipDisplay, _) = $0 { return clipDisplay.id == deletedClip.id }
                    return false
                }
            }
            newState.sections.removeAll { $0.items.isEmpty }
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
            let folderSortOption = try await self.fetchFolderSortOptionUseCase.execute().get()
            let clipSortOption = try await self.fetchClipSortOptionUseCase.execute().get()

            self.allFolders = folders
            self.allClips = clips
            self.folderSortOption = folderSortOption
            self.clipSortOption = clipSortOption

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

        let filteredFolders = searchFoldersUseCase.execute(query: trimmedQuery, in: allFolders)
        let filteredClips = searchClipsUseCase.execute(query: trimmedQuery, in: allClips)

        let sortedFolders = sortFoldersUseCase.execute(filteredFolders, by: folderSortOption)
        let sortedClips = sortClipsUseCase.execute(filteredClips, by: clipSortOption)

        let folderItems = sortedFolders.map { SearchItem.folder(folder: FolderDisplayMapper.map($0), query: trimmedQuery) }
        let clipItems = sortedClips.map { SearchItem.clip(clip: ClipDisplayMapper.map($0), query: trimmedQuery) }

        var sections: [SearchSectionModel] = []
        if !folderItems.isEmpty {
            sections.append(.init(section: .folderResults(headerTitle: "폴더"), items: folderItems))
        }
        if !clipItems.isEmpty {
            sections.append(.init(section: .clipResults(headerTitle: "클립"), items: clipItems))
        }

        return .setSections(sections)
    }
}
