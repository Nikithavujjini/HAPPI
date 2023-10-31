//
//  HacknosisApp.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 11/10/23.
//

import SwiftUI

@main
struct HacknosisApp: App {
    var body: some Scene {
        WindowGroup {
            RootScreenView()
                .onAppear {
                    NetworkReachability.shared.startMonitoring()
                }
        }
    }
}
