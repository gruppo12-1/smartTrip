//
//  ARTestView.swift
//  smartTrip
//
//  Created by Antonio Langella on 16/02/22.
//

import SwiftUI
import ARKit

struct ARTestView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State var pressedReset: Bool = false
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Button(action: {presentationMode.wrappedValue.dismiss()}, label: {Text("BACK")})
                        .padding(15.0)
                        .buttonStyle(.bordered)
                    Spacer()
                    Button(action: {pressedReset.toggle()}, label: {Text("RESET")})
                        .padding(15.0)
                        .buttonStyle(.bordered)
                }
                Spacer()
            }.zIndex(2)
            ARSCNViewContainer(pressedReset: $pressedReset)
                .edgesIgnoringSafeArea(.all)
                .zIndex(1)
        }
    }
}

struct ARSCNViewContainer: UIViewRepresentable {
    let view = ARSCNView(frame: .zero)
    @Binding var pressedReset: Bool
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ARSCNView {
        view.scene = SCNScene()
        view.delegate = context.coordinator
        
        let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapHandler(sender:)))
        view.addGestureRecognizer(gestureRecognizer)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal //informarsi su planeDetection! probabilmente indesiderata o da gestire a parte
        view.debugOptions = [.showFeaturePoints,.showWorldOrigin]
        view.session.run(config)
        
        return view
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if pressedReset != context.coordinator.lastPressedReset { //reset
            print("RESET")
            view.scene.rootNode.enumerateChildNodes(){
                node, stop in
                print(node)
                if let name = node.name {
                    if name == "box" {
                        print("rimuovo \(name)")
                        node.parent!.removeFromParentNode() //cancello il nodo associato all'anchor (il padre di node)
                    }
                }
            }
            context.coordinator.lastPressedReset.toggle()
            context.coordinator.objectPlaced = false
            context.coordinator.showPlanes(true)
        }
    }
    
    final class Coordinator: NSObject,ARSCNViewDelegate{
        let control: ARSCNViewContainer
        var lastPressedReset: Bool = false
        var objectPlaced: Bool = false
        private let planesOpacity: Double = 0.25
        
        init(_ control: ARSCNViewContainer){
            self.control = control
        }
        
        @objc func tapHandler(sender: UITapGestureRecognizer) {
            guard objectPlaced == false else {return}
            let view = control.view
            let location = sender.location(in: view)
            print(location)
            guard let hitTestResult = view.hitTest(location, types: [.estimatedHorizontalPlane]).first
                        else { return }
            print(hitTestResult)
            let anchor = ARAnchor(name: "boxanchor", transform: hitTestResult.worldTransform) //crea un anchor associata all'hitResult
            view.session.add(anchor: anchor)
            print(anchor)
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

            if let anchorPlane = anchor as? ARPlaneAnchor {
                print("NEW PLANE FOUND")
                guard let meshGeometry = ARSCNPlaneGeometry(device: control.view.device!) else {fatalError()}
                meshGeometry.update(from: anchorPlane.geometry)
                let material = SCNMaterial()
                material.diffuse.contents = Color.green
                meshGeometry.firstMaterial = material
                let meshNode = SCNNode(geometry: meshGeometry)
                meshNode.opacity = planesOpacity
                meshNode.name = "plane"
                node.addChildNode(meshNode)
            } //prima era planeanchor!!
            if anchor.name == "boxanchor" {
                print("posiziono modello")
                let boxNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
                boxNode.name = "box"
                objectPlaced = true
                //boxNode.simdPosition = SIMD3(planeAnchor.center.x, 0, planeAnchor.center.z)
                node.addChildNode(boxNode)
                showPlanes(false)
            }
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
                guard let planeAnchor = anchor as? ARPlaneAnchor, let plane = node.childNodes.first else { return }
                if let geometry = plane.geometry as? ARSCNPlaneGeometry{
                    geometry.update(from: planeAnchor.geometry)
                }
            }
        
        func showPlanes(_ cond: Bool){
            control.view.scene.rootNode.enumerateChildNodes({
                node, stop in
                if node.name == "plane" {
                    if cond {
                        node.opacity = planesOpacity
                    } else {
                        node.opacity = 0.0
                    }
                }
            })
        }
        /*
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            
            // Place content only for anchors found by plane detection.
                guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

                // Create a SceneKit plane to visualize the plane anchor using its position and extent.
                let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
                let planeNode = SCNNode(geometry: plane)
                planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)

                // Give the SCNNode a texture from Assets.xcassets to better visualize the detected plane.
                // NOTE: change this string to the name of the file you added
                planeNode.geometry?.firstMaterial?.diffuse.contents = "grid.png"

                /*
                 `SCNPlane` is vertically oriented in its local coordinate space, so
                 rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
                 */
                planeNode.eulerAngles.x = -.pi / 2

                // Make the plane visualization semitransparent to clearly show real-world placement.
                planeNode.opacity = 0.25

                /*
                 Add the plane visualization to the ARKit-managed node so that it tracks
                 changes in the plane anchor as plane estimation continues.
                 */
                node.addChildNode(planeNode)
        }
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
            guard let planeAnchor = anchor as?  ARPlaneAnchor,
                let planeNode = node.childNodes.first,
                let plane = planeNode.geometry as? SCNPlane
                else { return }

            // Plane estimation may shift the center of a plane relative to its anchor's transform.
            planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)

            /*
             Plane estimation may extend the size of the plane, or combine previously detected
             planes into a larger one. In the latter case, `ARSCNView` automatically deletes the
             corresponding node for one plane, then calls this method to update the size of
             the remaining plane.
            */
            plane.width = CGFloat(planeAnchor.extent.x)
            plane.height = CGFloat(planeAnchor.extent.z)
        }*/
    }
}

struct ARTestView_Previews: PreviewProvider {
    static var previews: some View {
        ARTestView()
.previewInterfaceOrientation(.portrait)
    }
}
