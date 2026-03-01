//
//  MapPlusApp.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 9/6/25.
//

import SwiftUI
import SwiftData

@main
struct MapPlusApp: App {

    @AppStorage("appTheme") private var appThemeRawValue: String = AppTheme.standard.rawValue

    private var appTheme: AppTheme {
        AppTheme(rawValue: appThemeRawValue) ?? .standard
    }

    var body: some Scene {
        WindowGroup {
            MainMapView()
                .environment(\.appTheme, appTheme)
                .applyTheme(appTheme)
        }
        .modelContainer(try! ModelContainer.persistentContainer())
    }
}

private extension View {
    @ViewBuilder
    func applyTheme(_ theme: AppTheme) -> some View {
        switch theme {
        case .standard:
            self
        case .eightBit:
            self.eightBitStyle()
        }
    }
}
