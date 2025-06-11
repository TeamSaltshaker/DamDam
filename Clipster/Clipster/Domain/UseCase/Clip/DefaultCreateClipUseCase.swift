//
//  DefaultCreateClipUseCase.swift
//  Clipster
//
//  Created by 유현진 on 6/11/25.
//

import Foundation

final class DefaultCreateClipUseCase: CreateClipUseCase {
    let clipRepository: ClipRepository

    init(clipRepository: ClipRepository) {
        self.clipRepository = clipRepository
    }

    func execute(_ clip: Clip) async -> Result<Void, Error> {
        clipRepository.createClip(clip).mapError { $0 as Error }
    }
}
