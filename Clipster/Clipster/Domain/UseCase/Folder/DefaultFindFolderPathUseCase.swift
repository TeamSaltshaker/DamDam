import Foundation

final class DefaultFindFolderPathUseCase: FindFolderPathUseCase {
    func execute(to target: Folder, in folders: [Folder]) -> [Folder]? {
        var stack: [(folder: Folder, path: [Folder])] = folders.map { ($0, [$0]) }

        while let (folder, path) = stack.popLast() {
            if folder.id == target.id {
                return path
            }

            for child in folder.folders {
                stack.append((child, path + [child]))
            }
        }

        return nil
    }
}
