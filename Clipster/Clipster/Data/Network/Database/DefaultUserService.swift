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

    func fetchUser(by id: UUID) async -> Result<User, Error> {
        do {
            let dto: UserDTO = try await client
                .from("Users")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            let user = mapper.user(from: dto)
            print("\(Self.self): ✅ Fetch Success. id: \(user.id), nickname: \(user.nickname)")
            return .success(user)
        } catch {
            print("\(Self.self): ❌ Fetch Failed. \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func insertUser(with id: UUID) async -> Result<Void, Error> {
        do {
            let dto = UserDTO(
                id: id,
                nickname: "김담담",
                createdAt: Date.now,
                updatedAt: Date.now,
                deletedAt: nil,
            )
            try await client
                .from("Users")
                .insert(dto)
                .execute()
            print("\(Self.self): ✅ Insert Success. id: \(id)")
            return .success(())
        } catch {
            print("\(Self.self): ❌ Insert Failed. \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func updateUser(_ dto: UserDTO) async -> Result<Void, Error> {
        do {
            try await client
                .from("Users")
                .update(["nickname": dto.nickname])
                .eq("id", value: dto.id)
                .execute()
            print("\(Self.self): ✅ Update Success. id: \(dto.id)")
            return .success(())
        } catch {
            print("\(Self.self): ❌ Update Failed. \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
