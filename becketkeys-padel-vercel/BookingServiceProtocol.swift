import Foundation

protocol BookingServiceProtocol {
    func fetchBookings(for day: Date) async throws -> [Booking]
    func saveBooking(courtNumber: Int, startDate: Date, staff: StaffUser) async throws
    func deleteBooking(_ booking: Booking) async throws
}
