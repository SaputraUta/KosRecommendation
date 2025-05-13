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
    @State private var deleteErrorMessage: String?
    @State private var deletingItemIds: Set<CKRecord.ID> = []
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView("Memuat rekomendasi kos...")
                        Text("Harap tunggu sebentar.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.red)
                        Text("Gagal Memuat")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        Button("Coba Lagi") {
                            Task {
                                await loadRecommendations()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                } else if model.kosRecommendations.isEmpty {
                    ContentUnavailableView("Belum Ada Rekomendasi Kos",
                                           systemImage: "house.slash",
                                           description: Text("Belum ada rekomendasi kos. Tambahkan yang pertama!")
                    )
                } else {
                    List {
                        ForEach(model.kosRecommendations) { kos in
                            NavigationLink(destination: KosDetailView(kos: kos)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(kos.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(kos.review)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                    Text(kos.datePosted.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.background)
                                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                )
                                .overlay(
                                    deletingItemIds.contains(kos.id) ?
                                    ProgressView().scaleEffect(0.6).padding() : nil
                                )
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteItem(kos)
                                } label: {
                                    Label("Hapus", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Daftar Kos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingForm = true
                    } label: {
                        Label("Tambah", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                    }
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
            .alert("Gagal Menghapus", isPresented: .constant(deleteErrorMessage != nil)) {
                Button("OK") {
                    deleteErrorMessage = nil
                }
            } message: {
                Text(deleteErrorMessage ?? "")
            }
        }
    }
    
    func loadRecommendations() async {
        isLoading = true
        errorMessage = nil
        do {
            try await model.populateRecommendations()
        } catch let error as CloudKitError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Terjadi kesalahan yang tidak diketahui"
        }
        isLoading = false
    }
    
    func deleteItem(_ kos: KosRecommendation) {
        deletingItemIds.insert(kos.id)
        Task {
            do {
                try await model.deleteRecommendation(kosItem: kos)
                deletingItemIds.remove(kos.id)
            } catch let error as CloudKitError {
                deleteErrorMessage = error.errorDescription
                deletingItemIds.remove(kos.id)
            } catch {
                deleteErrorMessage = "Terjadi kesalahan saat menghapus data"
                deletingItemIds.remove(kos.id)
            }
        }
    }
}

#Preview {
    KosRecommendationsList().environment(KosRecommendationViewModel())
}
