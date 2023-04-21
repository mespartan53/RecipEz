//
//  PhotoPickerView.swift
//  recipez
//
//  Created by Marcus Estrada on 4/15/23.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var didFinishPicking: (_ didSelectItems: Bool) -> Void
    typealias UIViewControllerType = PHPickerViewController
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
     
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        
        var photoPicker: PhotoPickerView
        
        init(with photoPicker: PhotoPickerView) {
            self.photoPicker = photoPicker
        }
        
        private func getPhoto(from itemProvider: NSItemProvider) {
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            withAnimation {
                                self.photoPicker.image = image
                            }
                        }
                    }
                }
            }
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            photoPicker.didFinishPicking(!results.isEmpty)
            
            guard !results.isEmpty else {
                return
            }
            
            let itemProvider = results[0].itemProvider
            self.getPhoto(from: itemProvider)
        }
    }
}

struct PhotoPickerView_Previews: PreviewProvider {
    @State static var image: UIImage?
    
    static var previews: some View {
        PhotoPickerView(image: $image) { didSelectItems in
            //
        }
    }
}
