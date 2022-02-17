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
                    if(item.isUnlocked){
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
                    }else{
                        Image(item.image)
                            .resizable()
                            .frame(width: 170, height: 170, alignment: .center)
                            .clipShape(Circle())
                            .overlay(Circle().stroke())
                            .padding()
                        Text("?")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Non hai ancora sbloccato questo contenuto.")
                            .font(.title2)
                            .foregroundColor(Color.blue)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
            .navigationTitle("Info")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(item: Item(title: "Torre Eiffel",image:"pic1", blackImage:"",desc:" La Torre Eiffel é una torre di ferro situata sugli Champ de Mars che prende il nome dal suo ingegnere Gustave Eiffel. Eretta nel 1889 come entrata dell' Esposizione Universale del 1889; é diventata l'icona della Francia e uno dei monumenti più conociuti al mondo. Con più di 7 milioni di visitatori l'anno, é il monumento più visitato al mondo. La Torre Eiffel é iscritta nei monumenti storici dopo il 24 giugno 1964 e iscritta nel patrimonio mondiale dell'UNESCO dopo il 1991.", isUnlocked: true))
    }
}
