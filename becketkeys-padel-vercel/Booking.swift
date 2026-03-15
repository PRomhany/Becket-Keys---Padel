import Foundation
import CloudKit

struct Booking: Identifiable, Hashable {
    let id: String
    let courtNumber: Int
    let startDate: Date
    let endDate: Date
    let staffName: String
    let staffEmail: String
    let createdAt: Date

    var slotLabel: String {
        "\(startDate.slotTimeString) – \(endDate.slotTimeString)"
    }

    var sessionTitle: String {
        if startDate.isMorningSlot {
            return "Morning session"
        }
        return "After-school session"
    }
}

extension Booking {
    static let recordType = "Booking"

    init?(record: CKRecord) {
        guard
            let id = record["recordId"] as? String,
            let startDate = record["startDate"] as? Date,
            let endDate = record["endDate"] as? Date,
            let staffName = record["staffName"] as? String,
            let staffEmail = record["staffEmail"] as? String,
            let createdAt = record["createdAt"] as? Date,
            let courtNumberValue = record["courtNumber"] as? Int64
        else {
            return nil
        }

        self.id = id
        self.courtNumber = Int(courtNumberValue)
        self.startDate = startDate
        self.endDate = endDate
        self.staffName = staffName
        self.staffEmail = staffEmail
        self.createdAt = createdAt
    }

    func asRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        record["recordId"] = id as CKRecordValue
        record["courtNumber"] = Int64(courtNumber) as CKRecordValue
        record["startDate"] = startDate as CKRecordValue
        record["endDate"] = endDate as CKRecordValue
        record["staffName"] = staffName as CKRecordValue
        record["staffEmail"] = staffEmail as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        return record
    }
}
