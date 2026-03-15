import Foundation

struct StaffUser: Codable, Equatable {
    let id: String
    let name: String
    let email: String
    let isAdmin: Bool
}
