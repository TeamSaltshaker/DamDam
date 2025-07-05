import Foundation
import Supabase

final class DefaultClipService: ClipService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchClip(by id: UUID) async -> Result<ClipDTO, DatabaseError> {
        do {
            let dto: ClipDTO = try await client
                .from("Clips")
                .select()
                .eq("id", value: id)
                .is("deletedAt", value: nil)
                .single()
                .execute()
                .value
            print("\(Self.self): ✅ Fetch success. title: \(dto.title)")
            return .success(dto)
        } catch {
            print("\(Self.self): ❌ Fetch failed. \(error.localizedDescription)")
            return .failure(.fetchFailed)
        }
    }

    func fetchAllClips() async -> Result<[ClipDTO], DatabaseError> {
        do {
            let dtoList: [ClipDTO] = try await client
                .from("Clips")
                .select()
                .is("deletedAt", value: nil)
                .execute()
                .value
            print("\(Self.self): ✅ Fetch success. Clips count: \(dtoList.count)")
            return .success(dtoList)
        } catch {
            print("\(Self.self): ❌ Fetch failed. \(error.localizedDescription)")
            return .failure(.fetchFailed)
        }
    }

    func fetchTopLevelClips() async -> Result<[ClipDTO], DatabaseError> {
        do {
            let dtoList: [ClipDTO] = try await client
                .from("Clips")
                .select()
                .is("parentID", value: nil)
                .is("deletedAt", value: nil)
                .execute()
                .value
            print("\(Self.self): ✅ Fetch success. Clips count: \(dtoList.count)")
            return .success(dtoList)
        } catch {
            print("\(Self.self): ❌ Fetch failed. \(error.localizedDescription)")
            return .failure(.fetchFailed)
        }
    }

    func fetchUnvisitedClips() async -> Result<[ClipDTO], DatabaseError> {
        do {
            let dtoList: [ClipDTO] = try await client
                .from("Clips")
                .select()
                .is("lastVisitedAt", value: nil)
                .is("deletedAt", value: nil)
                .execute()
                .value
            print("\(Self.self): ✅ Fetch success. Clips count: \(dtoList.count)")
            return .success(dtoList)
        } catch {
            print("\(Self.self): ❌ Fetch failed. \(error.localizedDescription)")
            return .failure(.fetchFailed)
        }
    }

    func fetchRecentVisitedClips(for ids: [UUID]) async -> Result<[ClipDTO], DatabaseError> {
        do {
            let dtoList: [ClipDTO] = try await client
                .from("Clips")
                .select()
                .in("id", values: ids)
                .is("deletedAt", value: nil)
                .execute()
                .value
            print("\(Self.self): ✅ Fetch success. Clips count: \(dtoList.count)")
            return .success(dtoList)
        } catch {
            print("\(Self.self): ❌ Fetch failed. \(error.localizedDescription)")
            return .failure(.fetchFailed)
        }
    }

    func insertClip(_ dto: ClipDTO) async -> Result<ClipDTO, DatabaseError> {
        do {
            let insertedDTO: ClipDTO = try await client
                .from("Clips")
                .insert(dto)
                .select()
                .single()
                .execute()
                .value
            print("\(Self.self): ✅ Insert success. title: \(insertedDTO.title)")
            return .success(insertedDTO)
        } catch {
            print("\(Self.self): ❌ Insert failed. \(error.localizedDescription)")
            return .failure(.insertFailed)
        }
    }

    func updateClip(_ dto: ClipDTO) async -> Result<ClipDTO, DatabaseError> {
        do {
            let updatedDTO: ClipDTO = try await client
                .from("Clips")
                .update(dto)
                .eq("id", value: dto.id)
                .is("deletedAt", value: nil)
                .select()
                .single()
                .execute()
                .value
            print("\(Self.self): ✅ Update success. title: \(updatedDTO.title)")
            return .success(updatedDTO)
        } catch {
            print("\(Self.self): ❌ Update failed. \(error.localizedDescription)")
            return .failure(.updateFailed)
        }
    }

    func deleteClip(_ dto: ClipDTO) async -> Result<ClipDTO, DatabaseError> {
        do {
            let deletedDTO: ClipDTO = try await client
                .from("Clips")
                .update(["deletedAt": Date.now])
                .eq("id", value: dto.id)
                .is("deletedAt", value: nil)
                .select()
                .single()
                .execute()
                .value
            print("\(Self.self): ✅ Delete success. title: \(deletedDTO.title)")
            return .success(deletedDTO)
        } catch {
            print("\(Self.self): ❌ Delete failed. \(error.localizedDescription)")
            return .failure(.deleteFailed)
        }
    }
}
