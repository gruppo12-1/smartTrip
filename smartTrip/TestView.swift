////
//  testView.swift
//  smartTrip
//
//  Created by Antonio Langella on 15/02/22.
//

import SwiftUI
import SceneKit

struct TestView: View {
 @Environment(\.managedObjectContext) private var viewContext
 @FetchRequest<CollectableItem>(entity: CollectableItem.entity(), sortDescriptors: []) var allitems: FetchedResults<CollectableItem>
 
 var body: some View {
  VStack{
   ForEach(allitems){ item in
    HStack{
     Text(item.name!)
     Spacer()
     if let p3Ddata=item.p3Ddata {
      try! SceneView(scene: SCNScene(url: p3Ddata), options: [.autoenablesDefaultLighting,.allowsCameraControl]).frame(width: 200,alignment: .center).border(.cyan, width: 1)
     } else {
      Image(uiImage: UIImage(data: item.previewImage!)!)
       .resizable(capInsets: EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1), resizingMode: .stretch )
       .aspectRatio(contentMode: .fit)
       .frame(width: 200.0)
     }
    }
    .frame(height: 150.0)
   }
   //try! SceneView(scene: SCNScene(url: Bundle.main.url(forResource: "colosseo", withExtension: "usdz")!), options: [.autoenablesDefaultLighting,.allowsCameraControl])
   Button("GO",action: {})
    
  }
 }
}

struct testView_Previews: PreviewProvider {
 static var previews: some View {
  TestView().environment(\.managedObjectContext, PersistanceController.preview.container.viewContext)
 }
}
