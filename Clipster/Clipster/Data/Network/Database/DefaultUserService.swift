import Foundation
import Supabase

final class DefaultUserService: UserService {
    private let client: SupabaseClient
    private let mapper: DomainMapper

    init(
        client: SupabaseClient,
        mapper: DomainMapper,
    ) {
        self.client = client
        self.mapper = mapper
    }

    func fetchUser(by id: UUID) async -> User? {
        do {
            let dto: UserDTO = try await client
                .from("Users")
                .select()
                .eq("id", value: id)
                .execute()
                .value
            return mapper.user(from: dto)
        } catch {
            print("\(Self.self): ❌ Fetch Failed. \(error.localizedDescription)")
            return nil
        }
    }
}
