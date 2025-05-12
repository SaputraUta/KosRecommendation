//
//  TodoViewModel.swift
//  PracticePublicDbCk
//
//  Created by Saputra on 12/05/25.
//

import Foundation
import CloudKit

enum CloudKitError: LocalizedError {
    case saveFailure
    case deleteFailure
    case loadFailure
    case networkFailure
    case permissionDenied
    case recordNotFound
    
    var errorDescription: String? {
        switch self {
        case .saveFailure:
            return "Gagal menyimpan rekomendasi kos. Silakan coba lagi."
        case .deleteFailure:
            return "Gagal menghapus rekomendasi kos. Silakan coba lagi."
        case .loadFailure:
            return "Tidak dapat memuat daftar kos. Periksa koneksi internet Anda."
        case .networkFailure:
            return "Masalah jaringan. Pastikan Anda terhubung ke internet."
        case .permissionDenied:
            return "Akses ditolak. Periksa pengaturan iCloud Anda."
        case .recordNotFound:
            return "Data tidak ditemukan. Mungkin sudah dihapus."
        }
    }
}

@Observable
class KosRecommendationViewModel {
    private var db = CKContainer.default().publicCloudDatabase
    private var KosRecommendationsDictionaries: [CKRecord.ID: KosRecommendation] = [:]
    
    var kosRecommendations: [KosRecommendation] {
        KosRecommendationsDictionaries.values.compactMap { $0 }
    }
    
    func addKosRecommendation(kosItem: KosRecommendation) async throws {
        do {
            let record = try await db.save(kosItem.record)
            guard let kosRecommendation = KosRecommendation(record: record) else {
                throw CloudKitError.saveFailure
            }
            KosRecommendationsDictionaries[kosRecommendation.id] = kosRecommendation
        } catch {
            if let cloudKitError = error as? CKError {
                switch cloudKitError.code {
                case .networkFailure, .networkUnavailable:
                    throw CloudKitError.networkFailure
                case .permissionFailure:
                    throw CloudKitError.permissionDenied
                default:
                    throw CloudKitError.saveFailure
                }
            } else {
                throw CloudKitError.saveFailure
            }
        }
    }
    
    func populateRecommendations() async throws {
        do {
            let query = CKQuery(recordType: RecordKeys.recordType, predicate: NSPredicate(value: true))
            query.sortDescriptors = [NSSortDescriptor(key: RecordKeys.datePosted, ascending: false)]
            let result = try await db.records(matching: query)
            let records = result.matchResults.compactMap { try? $0.1.get() }
            
            if records.isEmpty {
                throw CloudKitError.recordNotFound
            }
            
            records.forEach { record in
                KosRecommendationsDictionaries[record.recordID] = KosRecommendation(record: record)
            }
        } catch {
            if let cloudKitError = error as? CKError {
                switch cloudKitError.code {
                case .networkFailure, .networkUnavailable:
                    throw CloudKitError.networkFailure
                case .permissionFailure:
                    throw CloudKitError.permissionDenied
                default:
                    throw CloudKitError.loadFailure
                }
            } else {
                throw CloudKitError.loadFailure
            }
        }
    }
    
    func deleteRecommendation(kosItem: KosRecommendation) async throws {
        do {
            try await db.deleteRecord(withID: kosItem.id)
            KosRecommendationsDictionaries.removeValue(forKey: kosItem.id)
        } catch {
            if let cloudKitError = error as? CKError {
                switch cloudKitError.code {
                case .networkFailure, .networkUnavailable:
                    throw CloudKitError.networkFailure
                case .permissionFailure:
                    throw CloudKitError.permissionDenied
                case .unknownItem:
                    throw CloudKitError.recordNotFound
                default:
                    throw CloudKitError.deleteFailure
                }
            } else {
                throw CloudKitError.deleteFailure
            }
        }
    }
}
