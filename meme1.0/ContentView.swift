//
//  ContentView.swift
//  meme1.0
//
//  Created by Vinh on 22/04/2024.
//

import SwiftUI
import UIKit

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(bounds: view!.bounds)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)}
        
//        return  renderer.image { ctx in
//            view!.layer.render(in: ctx.cgContext)
//
//        }
    }
    
}

func renderImage() {
    let renderer = UIGraphicsImageRenderer(bounds: UIScreen.main.bounds)
    let capturedImage = renderer.image { ctx in
        UIApplication.shared.windows.first?.rootViewController?.view.layer.render(in: ctx.cgContext)
    }
    
    let activityViewController = UIActivityViewController(activityItems: [ capturedImage], applicationActivities: nil)
    UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    
}


struct ContentView: View {
    @State  var selectedImage: UIImage?
    @State private var capturedImage: UIImage?
    @State  var isShowingImagePicker = false
    @State  var text = ""

    var body: some View {
       // ZStack {
            VStack{
                AppBar(state: $selectedImage,viewController: UIApplication.shared.windows.first?.rootViewController ?? UIViewController())
                if selectedImage != nil {
                    VStack {
                        Spacer()
                        EditedImageView(image: $selectedImage, textTop: $text)
                            .padding()
                        Spacer()
                    }
                    .background(Color.black)

                    // Export Button
                          
                              Button("Capture & Share") {
                             var image =     EditedImageView(image: $selectedImage, textTop: $text).snapshot()
//                                  let swiftUIViewImage = VStack {
//                                      EditedImageView(image: $selectedImage, textTop: $text)
//
//                                  }.snapshot()
//
//                                  // Convert the SwiftUI snapshot to a UIImage
                                  let imageToShare = UIImage(cgImage: image.cgImage!)

                              let activityViewController = UIActivityViewController(activityItems: [ imageToShare], applicationActivities: nil)
                              UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)

                                      //     self.renderImage()
                                       }
                          }
                 else {
                    VStack {
                        Text("No Image Selected").foregroundColor(Color.white) // Display a message when no image is selected
                            .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill the available space
                    }
                    .background(Color.black) // Sets the background color to black
                }
                Footer(selectedImage: $selectedImage,isShowingImagePicker: $isShowingImagePicker)
            }
       // }
    }


 
    func renderImage() {
        let renderer = UIGraphicsImageRenderer(bounds: UIScreen.main.bounds)
        let capturedImage = renderer.image { ctx in
            UIApplication.shared.windows.first?.rootViewController?.view.layer.render(in: ctx.cgContext)
        }

        let activityViewController = UIActivityViewController(activityItems: [ capturedImage], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func captureAndShareView(image: UIImage?,
     textTop: String) {
            // Capture the SwiftUI view
//            let swiftUIViewImage = VStack {
//                EditedImageView(image: $image
//                                , textTop: $textTop)
//            }.snapshot()
//
//            // Convert the SwiftUI snapshot to a UIImage
//            let imageToShare = UIImage(cgImage: swiftUIViewImage.cgImage!)
//
//        let activityViewController = UIActivityViewController(activityItems: [ imageToShare], applicationActivities: nil)
//        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)

            
        
        }
}



// Helper struct to wrap ZStack in a View
struct ZStackView: View {
    let zStack: ContentView

    var body: some View {
        zStack
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                print("Selected image changed to \(uiImage.description)")
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
struct EditedImageView: View {
    @Binding var image: UIImage?
    @Binding var textTop: String
   // @State private var editedImage: UIImage? // New state variable
    @State  var textBottom = ""
    var body: some View {
        ZStack(alignment: .top) {
            if let editedImage = image {
                Image(uiImage: editedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .alignmentGuide(.top) { d in d[.top] }
                    .alignmentGuide(.leading) { d in d[.leading] }
                    .alignmentGuide(.trailing) { d in d[.trailing] }
                    .alignmentGuide(.bottom) { d in d[.bottom] }
            }
            VStack {
                TextField("", text: $textTop)
                    .foregroundColor(Color.white)
                    .font(.system(size: 20)).bold()
                    .placeholder(when: textTop.isEmpty) {
                        Text("TOP").foregroundColor(.white)
                }  .multilineTextAlignment(.center)

                Spacer()
                TextField("", text: $textBottom)
                    .foregroundColor(Color.white)
                    .font(.system(size: 20)).bold()
                    .placeholder(when: textBottom.isEmpty) {
                        Text("BOTTOM").foregroundColor(.white)
                }  .multilineTextAlignment(.center)
//                TextField("Enter Text", text: $text)
//                    .foregroundColor(Color.white)
//                    .font(.system(size: 20)).bold()
//                    .multilineTextAlignment(.center)
//                    .padding()
            }
        }

    }

}

struct AppBar: View {
    @Binding var state: UIImage?
    var viewController: UIViewController

    var body: some View {
        HStack {
            Button(action: {
                // Action for first button in app bar
                let imageToShare = UIImage(named: "yourImageName")
                //shareImage(image: state!, viewController: viewController)
                print("First Button in App Bar Tapped")
            }) {
                Image(systemName: "square.and.arrow.up").imageScale(.large)
            }
            Spacer()
            Button("Cancel") {
                print("Second Button in App Bar Tapped")
                state = nil
               // Image(systemName: "bell")
            }
        }
        .padding()
    }
}

struct Footer: View {
    @Binding var selectedImage: UIImage?
    @Binding  var isShowingImagePicker: Bool

    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                // Action for first button in footer
                print("First Button in Footer Tapped")
            }) {
                Image(systemName: "camera.fill").imageScale(.large)
            }
            Spacer()
            Button("Album") {
               // ImagePicker(selectedImage: $selectedImage)
                isShowingImagePicker.toggle()
            }
            .padding()
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            Spacer()
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .center,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
                .font(.system(size: 20)).bold()
            self
        }
    }
}




