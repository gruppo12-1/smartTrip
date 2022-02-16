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
            ContentView() //TODO: Decommentare in produzione
            //TestView().environment(\.managedObjectContext, PersistanceController.preview.container.viewContext)
        }
    }
}
