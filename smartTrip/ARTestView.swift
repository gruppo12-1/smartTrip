//
//  ARTestView.swift
//  smartTrip
//
//  Created by Antonio Langella on 16/02/22.
//

import SwiftUI
import ARKit

struct ARTestView: View {
    //@Environment(\.) var a
    
    @State var pressedReset: Bool = false
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Button(action: {print("BACK")}, label: {Text("BACK")})
                        .padding(15.0)
                        .buttonStyle(.bordered)
                    Spacer()
                    Button(action: {pressedReset = true}, label: {Text("RESET")})
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
        view.session.run(ARWorldTrackingConfiguration())
        
        return view
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if pressedReset {
            print("RESET")
            view.scene.rootNode.enumerateChildNodes(){
                node, stop in
                print(node)
                if let name = node.name {
                    print(name)
                    if name == "boxanchor" || name == "box" {
                        node.removeFromParentNode()
                    }
                }
            }
        }
    }
    
    final class Coordinator: NSObject,ARSCNViewDelegate{
        let control: ARSCNViewContainer
        
        init(_ control: ARSCNViewContainer){
            self.control = control
        }
        
        @objc func tapHandler(sender: UITapGestureRecognizer) {
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

            guard let anchor = anchor as? ARAnchor else { return } //prima era planeanchor!!
            print("SONO QUI")
            let boxNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
            boxNode.name = "box"
            
            //boxNode.simdPosition = SIMD3(planeAnchor.center.x, 0, planeAnchor.center.z)
            node.addChildNode(boxNode)
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
