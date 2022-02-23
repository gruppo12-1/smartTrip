//
//  CollectionView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//

import SwiftUI
import CoreData

struct CollectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var selectedItem: CollectableItem? = nil
    @State var selectedFilter: FilteringMethod = FilteringMethod.DEFAULT
    var body: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // 3 colonne
        
        GeometryReader { geo in
            let screenHeight = geo.frame(in: .global).height
            let screenWidth = geo.frame(in: .global).width
            ZStack {
                if screenHeight > screenWidth { //layout verticale
                    VStack(alignment: .center, content: {
                        HeaderView(item: selectedItem)
                        FilterBar(selectedFilter:$selectedFilter)
                            .padding(.horizontal)
                        
                        ScrollView{
                            LazyVGrid(columns: columns){
                                FilteredItems(filter: selectedFilter.predicate, selectedItem: $selectedItem)
                            }.padding(.all)
                        }
                    })
                } else { //layout verticale
                    HStack(alignment: .center, content: {
                        HeaderView(item: selectedItem)
                        ScrollView{
                            LazyVGrid(columns: columns){
                                FilteredItems(filter: selectedFilter.predicate, selectedItem: $selectedItem)
                            }.padding(.all)
                        }
                    })
                }
            }
        }
        .navigationTitle("My Collection")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ItemButtonStyle: ButtonStyle{
    @Environment(\.colorScheme) var colorScheme
    let cornerRadius: CGFloat
    func makeBody(configuration: Configuration) -> some View{
        ZStack{
            configuration.label
            if configuration.isPressed {
                Color.black.opacity(0.2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: colorScheme == .dark ? Color.white : Color.black, radius: 2)
    }
}

struct HeaderView: View{
    @Environment(\.colorScheme) var colorScheme
    @State var showingDetailsView = false
    @State var showingARView = false
    
    var item: CollectableItem?
    var isSelectedItemNull: Binding<Bool>
    var hasSelectedItemModel: Binding<Bool>
    
    init(item: CollectableItem?){
        self.item = item
        self.isSelectedItemNull = Binding(get:{item == nil},set: {_ in})
        self.hasSelectedItemModel = Binding(get:{item?.p3Ddata == nil},set: {_ in})
    }
    var body: some View{
        VStack{
            if item?.collectedItem != nil {
                Image(uiImage: UIImage(data: item!.previewImage!)!)
                    .resizable()
                    .frame(width: 170, height: 170)
                    .background(colorScheme == .dark ? Color.init(white: 0.1) : Color.init(white: 0.9))
                    .clipShape(Circle())
                    .overlay(Circle().stroke())
                
            } else {
                Image(systemName: "questionmark")
                    .resizable()
                    .frame(width: 70, height: 120, alignment: .center)
                    .foregroundColor(Color.blue)
                    .frame(width: 170, height: 170)
                    .background(colorScheme == .dark ? Color.init(white: 0.1) : Color.init(white: 0.9))
                    .clipShape(Circle())
                    .overlay(Circle().stroke())
            }
            HStack(spacing: 175.0){
                if (item != nil && item?.p3Ddata != nil){
                    VStack{
                        NavigationLink(destination: ARTestView(p3DModel: self.item!.p3Ddata!), label: {
                            VStack(spacing: 2.0){
                                Image(systemName: "arkit")
                                    .resizable()
                                    .frame(width: 40, height: 45)
                            }
                            
                        } )
                        Text("AR View")
                    }
                }else{
                    VStack{
                        Button(action: {
                            // Show Info
                            self.showingDetailsView = true
                        }, label: {
                            Image(systemName: "arkit")
                                .resizable()
                                .frame(width: 40, height: 45)
                        })
                            .disabled(true)
                        Text("AR View")
                    }
                }
                if (item != nil){
                    VStack{
                        NavigationLink(destination: DetailsView(item: self.item!), label: {
                            VStack(){
                                Image(systemName: "info.circle")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                
                                
                            }
                            
                        } )
                        Text("Info")
                    }
                }else{
                    VStack{
                        Button(action: {
                            // Show Info
                            self.showingDetailsView = true
                        }, label: {
                            Image(systemName: "info.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                        })
                            .disabled(true)
                        Text("Info")
                    }
                }
            }
        }
        .frame(height:280)
        .frame(maxWidth: .infinity)
    }
}

struct FilterBar: View{
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedFilter: FilteringMethod
    
     var filteringMethods: [FilteringMethod] {
        FilteringMethod.generateFilteringMethods(context: viewContext)
     }
    
    var body: some View{
        Menu(){
            let methods = filteringMethods
            ForEach(methods){ method in
                Button(action: {
                    selectedFilter = methods[method.id]
                }, label: {Text("\(method.name)")})
            }
        } label: {
            Text(selectedFilter.name)
        }
    }
}

struct FilteringMethod: Identifiable{
    let id: Int
    let name: String
    let predicate: NSPredicate?
    
    static let DEFAULT = FilteringMethod(id: 0,name:"Nessun Filtro",predicate: nil)
    
    static func generateFilteringMethods(context: NSManagedObjectContext) -> [FilteringMethod]{
        var methods: [FilteringMethod] = [self.DEFAULT]
        let req = NSFetchRequest<CollectedItem>(entityName: "CollectedItem")
        //req.predicate = NSPredicate(format: "collectedItem != nil")
        //req.propertiesToFetch = [NSArray arrayWithObjects:@"item.city", nil]
        req.returnsDistinctResults = true
        let cities = try! context.fetch(req).map({$0.item!.city!})
        var i = 1
        for city in cities {
            methods.append(
                FilteringMethod(id: i,
                                name: city,
                                predicate: NSPredicate(format: "item.city == %@",city))
            )
            i = i + 1
        }
        return methods
    }
}

struct FilteredItems: View {
    @FetchRequest var fetchedItems: FetchedResults<CollectedItem>
    @Binding var selectedItem: CollectableItem?
    
    init(filter: NSPredicate?, selectedItem: Binding<CollectableItem?>){
        _fetchedItems = FetchRequest<CollectedItem>(
            entity: CollectedItem.entity(),
            sortDescriptors: [],
            predicate:filter
        )
        self._selectedItem = selectedItem
    }
    var body: some View {
        ForEach(fetchedItems){ citem in
            Button(action:{
                // Show tapped image in circle
                selectedItem = citem.item
            }){
                ItemView(item: citem.item!)
            }
            .buttonStyle(ItemButtonStyle(cornerRadius: 20))
        }
    }
}

struct ItemView: View {
    @Environment(\.colorScheme) var colorScheme
    let item: CollectableItem
    let collected: Bool
    
    init(item: CollectableItem){
        self.item = item
        collected = (item.collectedItem != nil)
    }
    
    var body: some View{
        GeometryReader{ reader in
            VStack(spacing: 5){
                if collected {
                    Image(uiImage: UIImage(data: item.previewImage!)!)
                        .resizable()
                        .scaledToFit()
                        .frame(height:80)
                    Text(item.name!)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.9))
                }else{
                    Image(systemName: "questionmark")
                        .resizable()
                        .frame(width: 40, height: 70, alignment: .center)
                        .foregroundColor(Color.blue)
                }
            }
            .frame(width:reader.size.width, height: reader.size.height)
            .background(colorScheme == .dark ? Color.init(white: 0.1) : Color.init(white: 0.9))
        }
        .frame(height: 125)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color(UIColor.systemBackground), radius: 2)
    }
}

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionView()
            .environment(\.managedObjectContext, PersistanceController.preview.container.viewContext)
            .previewInterfaceOrientation(.portrait)
    }
}
