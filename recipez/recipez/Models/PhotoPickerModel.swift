//
//  PhotoPickerModel.swift
//  recipez
//
//  Created by Marcus Estrada on 4/15/23.
//

import SwiftUI
import Photos

struct PhotoPickerModel: Identifiable {
    var id: String
    var photo: UIImage?
    
    init(with photo: UIImage) {
        id = UUID().uuidString
        self.photo = photo
    }
}
