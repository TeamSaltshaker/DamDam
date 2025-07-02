import ReactorKit
import RxSwift
import UIKit

final class FolderSelectorViewController: UIViewController, View, UITableViewDelegate {
    typealias Reactor = FolderSelectorReactor

    var disposeBag = DisposeBag()
    private let folderSelectorView = FolderSelectorView()

    var onSelectionComplete: ((Folder?) -> Void)?

    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = folderSelectorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        folderSelectorView.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        reactor?.action.onNext(.viewDidLoad)
    }

    func bind(reactor: Reactor) {
        bindAction(to: reactor)
        bindState(from: reactor)
    }
}

private extension FolderSelectorViewController {
    func bindAction(to reactor: Reactor) {
        folderSelectorView.backButton.rx.tap
            .map { .backButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        folderSelectorView.selectButton.rx.tap
            .map { .selectButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        folderSelectorView.confirmButton.rx.tap
            .map { .selectButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    func bindState(from reactor: Reactor) {
        reactor.state
            .map(\.isAccordion)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isAccordion in
                self?.folderSelectorView.setDisplay(isAccordion)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.displayableFolders)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: folderSelectorView.tableView.rx.items) { [weak self] (tableView, row, folderDisplay) in
                guard let self, let reactor = self.reactor else {
                    return UITableViewCell()
                }

                if reactor.currentState.isAccordion {
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: AccordionCell.identifier,
                        for: IndexPath(row: row, section: 0)
                    ) as? AccordionCell else {
                        return UITableViewCell()
                    }

                    let isLastCell = (row == reactor.currentState.displayableFolders.count - 1)

                    cell.setDisplay(folderDisplay)
                    cell.setSeparator(isLastCell, for: folderDisplay.depth)
                    cell.expandAreaButton.rx.tap
                        .map { .toggleExpansion(id: folderDisplay.id) }
                        .bind(to: reactor.action)
                        .disposed(by: cell.disposeBag)

                    return cell
                } else {
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: FolderSelectorCell.identifier,
                        for: IndexPath(row: row, section: 0)
                    ) as? FolderSelectorCell else {
                        return UITableViewCell()
                    }

                    cell.setDisplay(folderDisplay)
                    return cell
                }
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.title)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] title in
                self?.folderSelectorView.commonNavigationView.setTitle(title)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.currentPath.isEmpty }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: folderSelectorView.backButton.rx.isHidden)
            .disposed(by: disposeBag)

        reactor.pulse(\.$phase)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] phase in
                guard let self = self else { return }
                switch phase {
                case .idle:
                    break
                case .loading:
                    break
                case .success(let selectedFolder):
                    self.onSelectionComplete?(selectedFolder)
                    self.dismiss(animated: true)
                case .error:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}

extension FolderSelectorViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let reactor else { return 0 }
        if reactor.currentState.isAccordion {
            return indexPath.row == 0 ? 48 : 44
        } else {
            return 72
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let reactor else { return }

        let selectedItem = reactor.currentState.displayableFolders[indexPath.row]
        reactor.action.onNext(.selectedFolder(id: selectedItem.id))
    }
}
