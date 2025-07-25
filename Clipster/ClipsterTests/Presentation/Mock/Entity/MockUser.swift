import Foundation
@testable import Clipster

enum MockUser {
    static let someUser: User = .init(
        id: UUID(),
        nickname: "김담담",
        createdAt: Date(),
        updatedAt: Date(),
        deletedAt: nil
    )
}
