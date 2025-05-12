//
//  KosRecommendation.swift
//  PracticePublicDbCk
//
//  Created by Saputra on 12/05/25.
//

import Foundation
import CloudKit
import CoreLocation

enum RecordKeys {
    static let recordType = "KosRecommendation"
    static let name = "name"
    static let review = "review"
    static let datePosted = "datePosted"
    static let location = "location"
}

struct KosRecommendation: Identifiable {
    let id: CKRecord.ID
    var name: String
    var review: String
    var datePosted: Date
    var location: CLLocation?
    
    init(id: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), name: String, review: String, datePosted: Date = Date(), location: CLLocation? = nil) {
        self.id = id
        self.name = name
        self.review = review
        self.datePosted = datePosted
        self.location = location
    }
    
    init?(record: CKRecord) {
        guard let name = record[RecordKeys.name] as? String,
              let review = record[RecordKeys.review] as? String,
              let datePosted = record[RecordKeys.datePosted] as? Date
        else {
            return nil
        }
        
        self.name = name
        self.review = review
        self.datePosted = datePosted
        self.location = record[RecordKeys.location] as? CLLocation
        self.id = record.recordID
    }
}

extension KosRecommendation {
    var record: CKRecord {
        let record = CKRecord(recordType: RecordKeys.recordType)
        record[RecordKeys.name] = name
        record[RecordKeys.review] = review
        record[RecordKeys.datePosted] = datePosted
        record[RecordKeys.location] = location
        return record
    }
}
