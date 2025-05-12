//
//  TodoViewModel.swift
//  PracticePublicDbCk
//
//  Created by Saputra on 12/05/25.
//

import Foundation
import CloudKit

@Observable
class KosRecommendationViewModel {
    private var db = CKContainer.default().publicCloudDatabase
    private var KosRecommendationsDictionaries: [CKRecord.ID: KosRecommendation] = [:]
    
    var kosRecommendations: [KosRecommendation] {
        KosRecommendationsDictionaries.values.compactMap { $0 }
    }
    
    func addKosRecommendation(kosItem: KosRecommendation) async throws {
        let record = try await db.save(kosItem.record)
        guard let kosRecommendation = KosRecommendation(record: record) else { return }
        KosRecommendationsDictionaries[kosRecommendation.id] = kosRecommendation
    }
}
