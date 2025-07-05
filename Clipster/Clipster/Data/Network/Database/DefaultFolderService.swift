import Foundation
import Supabase

final class DefaultFolderService: FolderService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchFolder(by id: UUID) async -> Result<FolderDTO, DatabaseError> {
        do {
            let dto: FolderDTO = try await client
                .from("Folders")
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

    func fetchAllFolders() async -> Result<[FolderDTO], DatabaseError> {
        do {
            let dtoList: [FolderDTO] = try await client
                .from("Folders")
                .select()
                .is("deletedAt", value: nil)
                .execute()
                .value
            print("\(Self.self): ✅ Fetch success. Folders count: \(dtoList.count)")
            return .success(dtoList)
        } catch {
            print("\(Self.self): ❌ Fetch failed. \(error.localizedDescription)")
            return .failure(.fetchFailed)
        }
    }

    func fetchTopLevelFolders() async -> Result<[FolderDTO], DatabaseError> {
        do {
            let dtoList: [FolderDTO] = try await client
                .from("Folders")
                .select()
                .is("parentID", value: nil)
                .is("deletedAt", value: nil)
                .execute()
                .value
            print("\(Self.self): ✅ Fetch success. Folders count: \(dtoList.count)")
            return .success(dtoList)
        } catch {
            print("\(Self.self): ❌ Fetch failed. \(error.localizedDescription)")
            return .failure(.fetchFailed)
        }
    }

    func insertFolder(_ dto: FolderDTO) async -> Result<FolderDTO, DatabaseError> {
        do {
            let insertedDTO: FolderDTO = try await client
                .from("Folders")
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

    func updateFolder(_ dto: FolderDTO) async -> Result<FolderDTO, DatabaseError> {
        do {
            let updatedDTO: FolderDTO = try await client
                .from("Folders")
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

    func deleteFolder(_ dto: FolderDTO) async -> Result<FolderDTO, DatabaseError> {
        do {
            let deletedAt = Date.now
            let deletedDTO: FolderDTO = try await client
                .from("Folders")
                .update(["deletedAt": deletedAt])
                .eq("id", value: dto.id)
                .is("deletedAt", value: nil)
                .select()
                .single()
                .execute()
                .value
            try await deleteFolderRecursively(deletedDTO, deletedAt: deletedAt)
            print("\(Self.self): ✅ Delete success. title: \(deletedDTO.title)")
            return .success(deletedDTO)
        } catch {
            print("\(Self.self): ❌ Delete failed. \(error.localizedDescription)")
            return .failure(.deleteFailed)
        }
    }

    private func deleteFolderRecursively(_ dto: FolderDTO, deletedAt: Date) async throws {
        do {
            let childFoldersDTOList: [FolderDTO] = try await client
                .from("Folders")
                .select()
                .eq("parentID", value: dto.id)
                .is("deletedAt", value: nil)
                .execute()
                .value

            for dto in childFoldersDTOList {
                try await client
                    .from("Folders")
                    .update(["deletedAt": deletedAt])
                    .eq("id", value: dto.id)
                    .execute()

                try await deleteFolderRecursively(dto, deletedAt: deletedAt)
            }

            let childClipsDTOList: [ClipDTO] = try await client
                .from("Clips")
                .select()
                .eq("parentID", value: dto.id)
                .is("deletedAt", value: nil)
                .execute()
                .value

            for dto in childClipsDTOList {
                try await client
                    .from("Clips")
                    .update(["deletedAt": deletedAt])
                    .eq("id", value: dto.id)
                    .execute()
            }
        } catch {
            throw DatabaseError.deleteFailed
        }
    }
}
