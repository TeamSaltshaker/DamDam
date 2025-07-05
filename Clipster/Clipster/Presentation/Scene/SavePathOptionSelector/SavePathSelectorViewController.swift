import RxSwift
import SnapKit
import UIKit

final class SavePathOptionSelectorViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let onSelect: (SavePathOption) -> Void
    private var selected: SavePathOption

    private let savePathOptionSelectorView = SavePathOptionSelectorView()

    init(selected: SavePathOption, onSelect: @escaping (SavePathOption) -> Void) {
        self.selected = selected
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = savePathOptionSelectorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        savePathOptionSelectorView.setDisplay(option: selected)
    }

    private func updateSelection(to option: SavePathOption) {
        guard selected != option else { return }

        selected = option
        onSelect(option)
        savePathOptionSelectorView.setDisplay(option: option)
    }
}

private extension SavePathOptionSelectorViewController {
    func configure() {
        setBindings()
    }

    func setBindings() {
        savePathOptionSelectorView.action
            .bind { [weak self] action in
                switch action {
                case .tapView(let option):
                    self?.updateSelection(to: option)
                }
            }
            .disposed(by: disposeBag)
    }
}
