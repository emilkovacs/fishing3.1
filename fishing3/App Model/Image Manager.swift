//
//  Image Manager.swift
//  fishing3
//
//  Created by Emil Kovács on 11. 7. 2025..
//


///`OLD VERSION HERE FOR REFERENCE ONLY`

/*
//Manages a single images based on a single UUID
/// Used to manage single images added to Bait, will be abstracted to a single function with the multi image manager?

@MainActor
@Observable
class SingleImageManager {
    let id: UUID
    var image: UIImage?
    
    var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(id.uuidString).jpg")
    }
    
    func loadImage() {
        let path = fileURL.path
        
        guard FileManager.default.fileExists(atPath: path) else {
            #if DEBUG
            print("No image found at \(path)")
            #endif
            self.image = nil
            return
        }

        if let loaded = UIImage(contentsOfFile: path) {
            self.image = loaded
        } else {
            #if DEBUG
            print("Failed to load UIImage from file at \(path)")
            #endif
            self.image = nil
        }
    }
    func saveImage(_ newImage: UIImage) {
        guard let data = newImage.jpegData(compressionQuality: 0.8) else {
            #if DEBUG
            print("Failed to create JPEG data from image.")
            #endif
            return
        }
        
        do {
            try data.write(to: self.fileURL, options: .atomic)
            self.image = newImage
        } catch {
            #if DEBUG
            print("Failed to save image to \(fileURL): \(error.localizedDescription)")
            #endif
        }
    }
    func deleteImage() {
        let path = fileURL.path
        guard FileManager.default.fileExists(atPath: path) else {
            #if DEBUG
            print("Image file does not exist at \(path)")
            #endif
            return
        }

        do {
            try FileManager.default.removeItem(at: fileURL)
            self.image = nil
        } catch {
            #if DEBUG
            print("Failed to delete image at \(path): \(error.localizedDescription)")
            #endif
        }
    }
    
    init(id: UUID) {
        self.id = id
        self.loadImage()
    }
}

*/
