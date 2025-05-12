//
//  KosRecommendationsList.swift
//  PracticePublicDbCk
//
//  Created by Saputra on 12/05/25.
//

import SwiftUI
import CoreLocation
import CloudKit.CKRecord

struct KosRecommendationsList: View {
    @Environment(KosRecommendationViewModel.self) var model
    @State private var isShowingForm = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var listErrorMessage: String?
    @State private var deleteErrorMessage: String?
    @State private var deletingItemIds: Set<CKRecord.ID> = []
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Memuat rekomendasi kos...")
                } else if let errorMessage = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .font(.system(size: 50))
                        Text("Gagal Memuat")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Ulangi") {
                            Task {
                                await loadRecommendations()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                } else if model.kosRecommendations.isEmpty {
                    ContentUnavailableView("Belum Ada Rekomendasi Kos",
                                           systemImage: "house.slash",
                                           description: Text("Belum ada rekomendasi kos. Tambahkan yang pertama!")
                    )
                } else {
                    List {
                        ForEach(model.kosRecommendations) { kos in
                            ZStack {
                                VStack(alignment: .leading) {
                                    Text(kos.name)
                                        .font(.headline)
                                    Text(kos.review)
                                        .font(.subheadline)
                                    Text(kos.datePosted.formatted())
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                .padding(.vertical, 8)
                                .opacity(deletingItemIds.contains(kos.id) ? 0.3 : 1)
                                
                                if deletingItemIds.contains(kos.id) {
                                    VStack {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                            .padding(.top, 4)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.ultraThinMaterial)
                                    .opacity(0.7)
                                }
                            }
                        }
                        .onDelete(perform: deleteRecommendation)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Daftar Kos")
            .toolbar {
                Button {
                    isShowingForm = true
                } label: {
                    Label("Tambah", systemImage: "plus")
                }
            }
            .sheet(isPresented: $isShowingForm) {
                NavigationStack {
                    FormKosRecommendationView()
                }
            }
            .refreshable {
                await loadRecommendations()
            }
            .task {
                await loadRecommendations()
            }
        }
    }
    
    func loadRecommendations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await model.populateRecommendations()
            isLoading = false
        } catch let error as CloudKitError {
            errorMessage = error.errorDescription
            isLoading = false
        } catch {
            errorMessage = "Terjadi kesalahan yang tidak diketahui"
            isLoading = false
        }
    }
    
    func deleteRecommendation(at offsets: IndexSet) {
        for index in offsets {
            let recommendationToDelete = model.kosRecommendations[index]
            deletingItemIds.insert(recommendationToDelete.id)
            Task {
                do {
                    try await model.deleteRecommendation(kosItem: recommendationToDelete)
                    deletingItemIds.remove(recommendationToDelete.id)
                } catch let error as CloudKitError {
                    deleteErrorMessage = error.errorDescription
                    deletingItemIds.remove(recommendationToDelete.id)
                } catch {
                    deleteErrorMessage = "Terjadi kesalahan saat menghapus data"
                    deletingItemIds.remove(recommendationToDelete.id)
                }
            }
        }
    }
}


#Preview {
    KosRecommendationsList().environment(KosRecommendationViewModel())
}
