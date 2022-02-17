//
//  DetailsView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//

import SwiftUI

struct DetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var item : Item
    
    init(item: Item){
        self.item = item
    }
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(alignment: .center, spacing: 16){
                    Image(item.image)
                        .resizable()
                        .frame(width: 170, height: 170, alignment: .center)
                        .clipShape(Circle())
                        .overlay(Circle().stroke())
                        .padding()
                    Text("Nome")
                        .font(.title2)
                        .foregroundColor(Color.blue)
                        .fontWeight(.semibold)
                    Text(item.title)
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Descrizione")
                        .font(.title2)
                        .foregroundColor(Color.blue)
                        .fontWeight(.semibold)
                    Text(item.desc)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
            .navigationTitle("Info")
            
        }
        
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(item: Item(title: "Torre Eiffel",image:"pic1", blackImage:"", desc:"", isUnlocked: true) )
    }
}
