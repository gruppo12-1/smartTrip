//
//  ContentView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        MapView()
    }
}


struct MapView: View {
    @State private var willMoveToInventory: Bool = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.70024528747822,
                                       longitude: 14.707543253794043),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )
    
    var body: some View {
        NavigationView{
            VStack{
                Map(coordinateRegion: $region)
                HStack{
                    NavigationLink(destination: CollectionView(), label: {Text("Inventario").padding(10)})
                    Spacer()
                    NavigationLink(destination: AccountView(), label: {Text("Profilo").padding(10)})
                }
            }.navigationBarHidden(true)
        }
        
        //.navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
