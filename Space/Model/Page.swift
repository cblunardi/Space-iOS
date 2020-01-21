struct PageResponse<Item>: Codable where Item: Codable {
    let items: [Item]
    let metadata: Metadata
}

struct Metadata: Codable {
    let page: Int
    let per: Int
    let total: Int
}

struct PageRequest {
    let page: Int
    let per: Int
}

