//
//  PersistanceController.swift
//  smartTrip
//
//  Created by Antonio Langella on 15/02/22.
//
import CoreData
import SwiftUI
import SwiftCSV

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
        readFromCSV(context: viewContext,path: Bundle.main.url(forResource: "luoghiSmartTrip", withExtension: "csv")!)
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
        item.desc = "L’Anfiteatro Flavio, più comunemente noto con il nome di Colosseo, si innalza nel cuore archeologico della città di Roma e accoglie quotidianamente un gran numero di visitatori attratti dal fascino della sua storia e della sua complessa architettura. L’edificio, detto Colosseo per via di una colossale statua che sorgeva nelle vicinanze, venne edificato nel I secolo d.C. per volere degli imperatori della dinastia flavia, ed ha accolto, fino alla fine dell’età antica, spettacoli di grande richiamo popolare, quali le cacce e i giochi gladiatori. L’edificio era, e rimane ancora oggi, uno spettacolo in se stesso. Si tratta infatti del più grande anfiteatro del mondo, in grado di offrire sorprendenti apparati scenografici, nonché servizi per gli spettatori. L’Anfiteatro Flavio, più comunemente noto con il nome di Colosseo, si innalza nel cuore archeologico della città di Roma e accoglie quotidianamente un gran numero di visitatori attratti dal fascino della sua storia e della sua complessa architettura. L’edificio, detto Colosseo per via di una colossale statua che sorgeva nelle vicinanze, venne edificato nel I secolo d.C. per volere degli imperatori della dinastia flavia, ed ha accolto, fino alla fine dell’età antica, spettacoli di grande richiamo popolare, quali le cacce e i giochi gladiatori. L’edificio era, e rimane ancora oggi, uno spettacolo in se stesso. Si tratta infatti del più grande anfiteatro del mondo, in grado di offrire sorprendenti apparati scenografici, nonché servizi per gli spettatori."
        item.latitude = 41.890243828691496
        item.longitude = 12.492232249150172
        item.type = 0
        item.rarity = 0
        item.previewImage = UIImage(named: "colosseo.png")!.pngData()
        item.p3Ddata = Bundle.main.url(forResource: "colosseo", withExtension: "usdz")
        item.city="Roma"
        
        let item2 = CollectableItem(context: context)
        item2.id = UUID()
        item2.name = "Torre Eiffel"
        item2.desc = "La Torre Eiffel é una torre di ferro situata sugli Champ de Mars che prende il nome dal suo ingegnere Gustave Eiffel. Eretta nel 1889 come entrata dell' Esposizione Universale del 1889; é diventata l'icona della Francia e uno dei monumenti più conociuti al mondo. Con più di 7 milioni di visitatori l'anno, é il monumento più visitato al mondo. La Torre Eiffel é iscritta nei monumenti storici dopo il 24 giugno 1964 e iscritta nel patrimonio mondiale dell'UNESCO dopo il 1991."
        item2.latitude = 41.890243828691496
        item2.longitude = 12.492232249150172
        item2.type = 0
        item2.rarity = 0
        item2.previewImage = UIImage(named: "eiffel.png")!.pngData()
        item2.city="Parigi"
        let item3 = CollectableItem(context: context)
        item3.id = UUID()
        item3.name = "Big Ben"
        item3.desc = "L'edificio delle Houses of Parliament e la Elisabeth Tower, comunemente denominata Big Ben, sono tra i monumenti più rappresentativi di Londra. Tecnicamente, Big Ben è il nome assegnato alla massiccia campana, del peso di oltre 13 tonnellate (13.760 kg), che si trova all'interno della torre dell'orologio. La torre dell'orologio offre uno spettacolo straordinario di notte quando i quattro quadranti sono illuminati."
        item3.latitude = 41.890243828691496
        item3.longitude = 12.492232249150172
        item3.type = 0
        item3.rarity = 0
        item3.previewImage = UIImage(named: "big-ben.png")!.pngData()
        item3.city="Londra"
        
        //Item di prova da eliminare
        let item4 = CollectableItem(context: context)
        item4.id = UUID()
        item4.name = "Big Ben nel giardino di Teodoro"
        item4.desc = "Test di unlock"
        item4.latitude = 40.730732
        item4.longitude = 14.693297
        item4.type = 0
        item4.rarity = 0
        item4.previewImage = UIImage(named: "big-ben.png")!.pngData()
        item4.city="Cava"
        // Item di prova per il test a cava
        
        let item5 = CollectableItem(context: context)
        item5.id = UUID()
        item5.name = "San Francesco"
        item5.desc = "Test di unlock"
        item5.latitude = 40.69630646643192
        item5.longitude = 14.710099141708417
        item5.type = 0
        item5.rarity = 0
        item5.previewImage = UIImage(named: "big-ben.png")!.pngData()
        item5.city="Cava"
        
        let item6 = CollectableItem(context: context)
        item6.id = UUID()
        item6.name = "Duomo"
        item6.desc = "Test di unlock"
        item6.latitude = 40.70022710777279
        item6.longitude = 14.707599322971044
        item6.type = 0
        item6.rarity = 0
        item6.previewImage = UIImage(named: "big-ben.png")!.pngData()
        item6.city="Milano"
        
        let item7 = CollectableItem(context: context)
        item7.id = UUID()
        item7.name = "Parco Betoween"
        item7.desc = "Test di unlock"
        item7.latitude = 40.70608323761493
        item7.longitude = 14.703447263501785
        item7.type = 0
        item7.rarity = 0
        item7.previewImage = UIImage(named: "big-ben.png")!.pngData()
        item7.city="Cava"
        
        let item8 = CollectableItem(context: context)
        item8.id = UUID()
        item8.name = "Mediateca Marte"
        item8.desc = "Test di unlock"
        item8.latitude = 40.69843531868067
        item8.longitude = 14.709213682278818
        item8.type = 0
        item8.rarity = 0
        item8.previewImage = UIImage(named: "big-ben.png")!.pngData()
        item8.city="Cava"
        let item9 = CollectableItem(context: context)
        item9.id = UUID()
        item9.name = "Bar di Ingegneria"
        item9.desc = "Compra un po' d'acqua di Fisciano"
        item9.latitude = 40.772221184386744
        item9.longitude = 14.791195899108711
        item9.type = 0
        item9.rarity = 0
        item9.previewImage = UIImage(named: "big-ben.png")!.pngData()
        item9.city="Fisciano"
        
        let item10 = CollectableItem(context: context)
        item10.id = UUID()
        item10.name = "Fine dell' Edificio E"
        item10.desc = "Test di unlock"
        item10.latitude = 40.77355368309907
        item10.longitude = 14.790139108820384
        item10.type = 0
        item10.rarity = 0
        item10.previewImage = UIImage(named: "big-ben.png")!.pngData()
        item10.city="Fisciano"
        
        
        
        
        
        let item11 = CollectableItem(context: context)
        item11.id = UUID()
        item11.name = "Passiano"
        item11.desc = "Test di unlock"
        item11.latitude = 40.70342907718749
        item11.longitude = 14.69354161470204
        item11.type = 0
        item11.rarity = 0
        item11.previewImage = UIImage(named: "big-ben.png")!.pngData()
        item11.city="Cava de' Tirreni"
        
        
        // Altre cose
        
        let collected1 = CollectedItem(context: context)
        collected1.id = UUID()
        collected1.dateCollected = Date()
        collected1.item = item
        
        let collected2 = CollectedItem(context: context)
        collected2.id = UUID()
        collected2.dateCollected = Date()
        collected2.item = item2
    }
    
    private static func readFromCSV(context: NSManagedObjectContext, path: URL){
        let csv = try! CSV(url: path,delimiter: ";")
        print(csv.header)
        for row in csv.namedRows {
            let item = CollectableItem(context: context)
            item.id = UUID()
            item.name = row["Nome"]!
            item.desc = row["Descrizione"]!
            item.latitude = Float(row["Latitudine"]!)!
            item.longitude = Float(row["Longitudine"]!)!
            item.type = 0
            item.rarity = 0
            item.previewImage = UIImage(named: "\(row["Nome"]!).png")?.pngData() ?? UIImage(named: "unknown.png")?.pngData()
            item.city = row["Citta"]!
            item.category = row["Categoria"]!
            if let p3Ddata = Bundle.main.url(forResource: "\(row["Nome"]!)", withExtension: "usdz") {
                item.p3Ddata = p3Ddata
            }
            
            let collected = CollectedItem(context: context)
            collected.id = UUID()
            collected.dateCollected = Date()
            collected.item = item
        }
    }
}
