//
//  smartTripApp.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//

import SwiftUI

@main
struct smartTripApp: App {
    let persistanceController = PersistanceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, PersistanceController.preview.container.viewContext) //TODO: Decommentare in produzione
            //ARTestView()
            //TestView().environment(\.managedObjectContext, PersistanceController.preview.container.viewContext)
        }
    }
}
