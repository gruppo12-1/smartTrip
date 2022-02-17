//
//  DetailsView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//

import SwiftUI
import CoreData

struct DetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var item : CollectableItem
    let unlocked: Bool
    
    init(item: CollectableItem){
        self.item = item
        unlocked = item.collectedItem != nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(alignment: .center, spacing: 16){
                    if(unlocked){
                        Image(uiImage: UIImage(data: item.previewImage!)!)
                            .resizable()
                            .frame(width: 170, height: 170, alignment: .center)
                            .clipShape(Circle())
                            .overlay(Circle().stroke())
                            .padding()
                        Text("Nome")
                            .font(.title2)
                            .foregroundColor(Color.blue)
                            .fontWeight(.semibold)
                        Text(item.name!)
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Descrizione")
                            .font(.title2)
                            .foregroundColor(Color.blue)
                            .fontWeight(.semibold)
                        Text(item.desc!)
                            .font(.subheadline)
                    }else{
                        Image("")
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
    static var item = { () -> CollectableItem in
        let context = PersistanceController.preview.container.viewContext
        let req = NSFetchRequest<CollectableItem>(entityName: "CollectableItem")
        req.predicate = NSPredicate(format:"name LIKE %@","Torre Eiffel")
        let res = try! context.fetch(req)
        return res.first!
    }()
    
    static var previews: some View {
        
        DetailsView(item: item)
    }
}
