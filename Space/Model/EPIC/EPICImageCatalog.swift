struct EPICImageCatalog {
    let date: String
    let images: [EPICImageEntry]
}

extension EPICImageCatalog: Identifiable {
    var id: String { date }
}

extension EPICImageCatalog: Equatable {
    static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension EPICImageCatalog {
    init(date: EPICDateEntry, images: [EPICImageEntry]) {
        self.date = date.date
        self.images = images
    }

    init?(images: [EPICImageEntry]) {
        guard let date = images.first?.date else {
            return nil
        }

        self.date = date
        self.images = images
    }
}
