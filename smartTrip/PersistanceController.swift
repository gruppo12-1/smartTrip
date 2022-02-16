//
//  PersistanceController.swift
//  smartTrip
//
//  Created by Antonio Langella on 15/02/22.
//
import CoreData
import SwiftUI

struct PersistanceController{
    static let shared = PersistanceController() //Singleton. Sto costruendo la classe stessa!!!
    //TODO: In fase di produzione togliere inMemory: true
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false){
        container = NSPersistentContainer(name: "SmartTripModel") //il nome del modello dev'essere lo stesso del file
        if inMemory { //Se inMemory == true, i dati vanno salvati in un file temporaneo
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        //Altrimenti genera lui il nome del file ed esso non sarà volatile
        container.loadPersistentStores(completionHandler: {storeDescription,error in 
            if let error = error as NSError?{
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }) //completionHandler viene eseguita dopo il caricamento e gestisce eventuali errori in fase di caricamento
    }
    
    static var preview: PersistanceController = { //Parte extra per gestire le preview.
        let result = PersistanceController(inMemory: true) //Inizializza un contenitore volatile con elementi fittizzi
        let viewContext = result.container.viewContext
        let item = CollectableItem(context: viewContext)
        item.id = UUID()
        item.name = "Colosseo"
        item.desc = "Anfiteatro romano del ... secolo"
        item.latitude = 41.890243828691496
        item.longitude = 12.492232249150172
        item.type = 0
        item.rarity = 0
        item.previewImage = UIImage(named: "colosseo.png")!.pngData()
        item.p3Ddata = Bundle.main.url(forResource: "colosseo", withExtension: "usdz")
        
        let item2 = CollectableItem(context: viewContext)
        item2.id = UUID()
        item2.name = "Colosseo2"
        item2.desc = "Anfiteatro romano del ... secolo"
        item2.latitude = 41.890243828691496
        item2.longitude = 12.492232249150172
        item2.type = 0
        item2.rarity = 0
        item2.previewImage = UIImage(named: "colosseo.png")!.pngData()
        let item3 = CollectableItem(context: viewContext)
        item3.id = UUID()
        item3.name = "Colosseo3"
        item3.desc = "Anfiteatro romano del ... secolo"
        item3.latitude = 41.890243828691496
        item3.longitude = 12.492232249150172
        item3.type = 0
        item3.rarity = 0
        item3.previewImage = UIImage(named: "colosseo.png")!.pngData()
        do{
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
