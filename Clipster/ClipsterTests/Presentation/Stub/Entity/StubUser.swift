import Foundation
@testable import Clipster

enum StubUser {
    static let someUser: User = .init(
        id: UUID(),
        nickname: "김담담",
        createdAt: Date(),
        updatedAt: Date(),
        deletedAt: nil
    )
}
