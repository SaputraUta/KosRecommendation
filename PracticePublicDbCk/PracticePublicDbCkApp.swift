//
//  PracticePublicDbCkApp.swift
//  PracticePublicDbCk
//
//  Created by Saputra on 12/05/25.
//

import SwiftUI

@main
struct PracticePublicDbCkApp: App {
    @State private var model = KosRecommendationViewModel()
    var body: some Scene {
        WindowGroup {
            KosRecommendationsList().environment(model)
        }
    }
}
