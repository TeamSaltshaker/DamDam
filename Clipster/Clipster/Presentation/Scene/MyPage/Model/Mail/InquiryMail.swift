import UIKit

enum InquiryMail {
    enum Alert {
        static let title = "메일을 보낼 수 없습니다"
        static let message = "iOS Mail 앱에 계정이 설정되어 있어야 합니다."
    }

    static let recipient = "youseokhwan15@gmail.com"
    static let subject = "[담담 문의]"

    static func body() -> String {
        let systemVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let deviceModel = UIDevice.current.model

        return """
        문의 내용을 입력해주세요.

        ----------
        iOS 버전: \(systemVersion)
        앱 버전: \(appVersion)
        기기 모델: \(deviceModel)
        ----------
        """
    }
}
