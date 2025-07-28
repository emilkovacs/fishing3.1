//
//  Image Manager.swift
//  fishing3
//
//  Created by Emil Kovács on 11. 7. 2025..
//

import SwiftUI

actor ImageManager {
    static let shared = ImageManager()

    private static let documentsURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()

    func saveImage(_ image: UIImage, fileID: UUID) async -> UUID? {
        await Task.detached(priority: .utility) {
            guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
            let fileURL = ImageManager.documentsURL.appendingPathComponent("\(fileID).jpg")

            do {
                try data.write(to: fileURL, options: .atomic)
                return fileID
            } catch {
                return nil
            }
        }.value
    }

    func loadImage(_ fileID: UUID) async -> UIImage? {
        await Task.detached(priority: .utility) {
            let fileURL = ImageManager.documentsURL.appendingPathComponent("\(fileID).jpg")
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
            return UIImage(contentsOfFile: fileURL.path)
        }.value
    }

    func deleteImage(_ fileID: UUID) async -> Bool {
        await Task.detached(priority: .utility) {
            let fileURL = ImageManager.documentsURL.appendingPathComponent("\(fileID).jpg")
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return false }

            do {
                try FileManager.default.removeItem(at: fileURL)
                return true
            } catch {
                return false
            }
        }.value
    }
}

