//
//  KosRecommendationsList.swift
//  PracticePublicDbCk
//
//  Created by Saputra on 12/05/25.
//

import SwiftUI
import CoreLocation

struct KosRecommendationsList: View {
    @Environment(KosRecommendationViewModel.self) var model
    @State private var isShowingForm = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(model.kosRecommendations) { kos in
                    VStack(alignment: .leading) {
                        Text(kos.name)
                            .font(.headline)
                        Text(kos.review)
                            .font(.subheadline)
                        Text(kos.datePosted.formatted())
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
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
        }
    }
}

#Preview {
    KosRecommendationsList().environment(KosRecommendationViewModel())
}
