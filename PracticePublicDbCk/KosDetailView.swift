//
//  KosDetailView.swift
//  PracticePublicDbCk
//
//  Created by Saputra on 13/05/25.
//

import SwiftUI
import MapKit

struct KosDetailView: View {
    let kos: KosRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(kos.name)
                .font(.title)
                .bold()
            
            Text(kos.review)
                .font(.body)
            
            if let location = kos.location?.coordinate {
                var point = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))) {
                    Annotation("Lokasi Kos", coordinate: point) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.red)
                            .font(.title)
                    }
                }
                .frame(height: 250)
                
                Button(action: {
                    openInMaps(coordinate: location)
                }) {
                    Label("Lihat di Apple Maps", systemImage: "map")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
            } else {
                Text("Lokasi tidak tersedia")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Detail Kos")
    }
    
    private func openInMaps(coordinate: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = kos.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

#Preview {
    let sampleKos = KosRecommendation(
        name: "Kos Asri Kuta", review: "Tempatnya nyaman dan strategis dekat pantai Kuta.", location: CLLocation(latitude: -8.719083, longitude: 115.1699)
    )
    NavigationStack {
        KosDetailView(kos: sampleKos)
    }
}
