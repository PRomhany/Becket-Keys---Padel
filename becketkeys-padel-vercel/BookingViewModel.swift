import Foundation
import SwiftUI

@MainActor
final class BookingViewModel: ObservableObject {
    @Published var selectedDate = Date().startOfDayLocal
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let service: BookingServiceProtocol
    private weak var authViewModel: AuthViewModel?

    init(service: BookingServiceProtocol = CloudKitBookingService()) {
        self.service = service
    }

    func attachAuthViewModel(_ authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }

    var currentUser: StaffUser? {
        authViewModel?.currentUser
    }

    var slots: [Date] {
        Date.validSlots(for: selectedDate)
    }

    func loadBookings() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            bookings = try await service.fetchBookings(for: selectedDate)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func moveDay(by amount: Int) {
        selectedDate = Calendar.current.date(byAdding: .day, value: amount, to: selectedDate) ?? selectedDate
    }

    func goToToday() {
        selectedDate = Date().startOfDayLocal
    }

    func booking(for courtNumber: Int, slotStart: Date) -> Booking? {
        bookings.first {
            $0.courtNumber == courtNumber && Calendar.current.isDate($0.startDate, equalTo: slotStart, toGranularity: .minute)
        }
    }

    func canBook(_ slotStart: Date, on courtNumber: Int) -> Bool {
        guard let currentUser else { return false }
        guard booking(for: courtNumber, slotStart: slotStart) == nil else { return false }

        let today = Date().startOfDayLocal
        let lastAllowedDay = Calendar.current.date(byAdding: .day, value: SchoolConfig.maxAdvanceBookingDays, to: today) ?? today

        guard slotStart >= today else { return false }
        guard slotStart <= lastAllowedDay else { return false }

        if !SchoolConfig.allowsSameUserMultipleBookingsPerDay {
            let alreadyBookedToday = bookings.contains { $0.staffEmail == currentUser.email }
            if alreadyBookedToday { return false }
        }

        return true
    }

    func book(courtNumber: Int, slotStart: Date) async {
        guard let currentUser else {
            errorMessage = "Please sign in first."
            return
        }

        guard canBook(slotStart, on: courtNumber) else {
            errorMessage = "This slot is not available."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await service.saveBooking(courtNumber: courtNumber, startDate: slotStart, staff: currentUser)
            await loadBookings()
            successMessage = "Court \(courtNumber) booked for \(slotStart.slotTimeString)."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancel(_ booking: Booking) async {
        guard let currentUser else { return }
        guard booking.staffEmail.lowercased() == currentUser.email.lowercased() || currentUser.isAdmin else {
            errorMessage = "Only the booking owner or an admin can cancel this slot."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await service.deleteBooking(booking)
            await loadBookings()
            successMessage = "Booking cancelled."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func bookingsForUser(on day: Date) -> [Booking] {
        guard let currentUser else { return [] }
        return bookings.filter {
            Calendar.current.isDate($0.startDate, inSameDayAs: day) &&
            $0.staffEmail.lowercased() == currentUser.email.lowercased()
        }
    }
}
