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
        generateDummyContent(context: viewContext)
        do{
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    private static func generateDummyContent(context: NSManagedObjectContext){
        let item = CollectableItem(context: context)
        item.id = UUID()
        item.name = "Colosseo"
        item.desc = "L’Anfiteatro Flavio, più comunemente noto con il nome di Colosseo, si innalza nel cuore archeologico della città di Roma e accoglie quotidianamente un gran numero di visitatori attratti dal fascino della sua storia e della sua complessa architettura. L’edificio, detto Colosseo per via di una colossale statua che sorgeva nelle vicinanze, venne edificato nel I secolo d.C. per volere degli imperatori della dinastia flavia, ed ha accolto, fino alla fine dell’età antica, spettacoli di grande richiamo popolare, quali le cacce e i giochi gladiatori. L’edificio era, e rimane ancora oggi, uno spettacolo in se stesso. Si tratta infatti del più grande anfiteatro del mondo, in grado di offrire sorprendenti apparati scenografici, nonché servizi per gli spettatori."
        item.latitude = 41.890243828691496
        item.longitude = 12.492232249150172
        item.type = 0
        item.rarity = 0
        item.previewImage = UIImage(named: "colosseo.png")!.pngData()
        item.p3Ddata = Bundle.main.url(forResource: "colosseo", withExtension: "usdz")
        
        let item2 = CollectableItem(context: context)
        item2.id = UUID()
        item2.name = "Torre Eiffel"
        item2.desc = "La Torre Eiffel é una torre di ferro situata sugli Champ de Mars che prende il nome dal suo ingegnere Gustave Eiffel. Eretta nel 1889 come entrata dell' Esposizione Universale del 1889; é diventata l'icona della Francia e uno dei monumenti più conociuti al mondo. Con più di 7 milioni di visitatori l'anno, é il monumento più visitato al mondo. La Torre Eiffel é iscritta nei monumenti storici dopo il 24 giugno 1964 e iscritta nel patrimonio mondiale dell'UNESCO dopo il 1991."
        item2.latitude = 41.890243828691496
        item2.longitude = 12.492232249150172
        item2.type = 0
        item2.rarity = 0
        item2.previewImage = UIImage(named: "eiffel.png")!.pngData()
        let item3 = CollectableItem(context: context)
        item3.id = UUID()
        item3.name = "Big Ben"
        item3.desc = "L'edificio delle Houses of Parliament e la Elisabeth Tower, comunemente denominata Big Ben, sono tra i monumenti più rappresentativi di Londra. Tecnicamente, Big Ben è il nome assegnato alla massiccia campana, del peso di oltre 13 tonnellate (13.760 kg), che si trova all'interno della torre dell'orologio. La torre dell'orologio offre uno spettacolo straordinario di notte quando i quattro quadranti sono illuminati."
        item3.latitude = 41.890243828691496
        item3.longitude = 12.492232249150172
        item3.type = 0
        item3.rarity = 0
        item3.previewImage = UIImage(named: "big-ben.png")!.pngData()
        
        let collected1 = CollectedItem(context: context)
        collected1.id = UUID()
        collected1.dateCollected = Date()
        collected1.item = item
        
        let collected2 = CollectedItem(context: context)
        collected2.id = UUID()
        collected2.dateCollected = Date()
        collected2.item = item2
    }
}
