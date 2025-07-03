struct URLMetadataDisplayMapper {
    static func map(urlMetaData: URLMetadata?) -> URLMetadataDisplay? {
        urlMetaData.map {
            URLMetadataDisplay(
                url: $0.url,
                title: $0.title,
                description: $0.description,
                thumbnailImageURL: $0.thumbnailImageURL,
                screenshotImageData: $0.screenshotData
            )
        }
    }
}
