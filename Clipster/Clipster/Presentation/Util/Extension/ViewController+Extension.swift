import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedBackground() {
         let tapEvent = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
         tapEvent.cancelsTouchesInView = false
         view.addGestureRecognizer(tapEvent)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func presentDeleteAlert(
        title: String,
        message: String = "삭제하겠습니까?",
        onCancel: @escaping () -> Void = {},
        onConfirm: @escaping () -> Void
    ) {
        let trimmedTitle = title.count > 20
            ? String(title.prefix(20)) + "..."
            : title

        let alert = UIAlertController(
            title: trimmedTitle,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in
            onCancel()
        })
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
            onConfirm()
        })

        present(alert, animated: true)
    }
}
