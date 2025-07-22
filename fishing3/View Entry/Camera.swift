//
//  Camera.swift
//  fishing3
//
//  Created by Emil Kovács on 21. 7. 2025..
//

import SwiftUI
import AVFoundation
import UIKit
import CoreImage

struct CameraView: View {
    
    @Binding var image: UIImage?
    var aspectRatio: CGFloat
    @Binding var display: Bool
    
    
    ///Internal variables
    @State var viewModel: CameraViewModel = CameraViewModel()
    @State private var showDarkOverlay: Bool = false
    @State private var appeared: Bool = false
    
    @ViewBuilder
    var body: some View {
        ZStack(alignment:.top){
        
            CameraPreview(session: viewModel.session)
                .background(AppColor.tone)
                .overlay{
                    if image != nil {
                        Image(uiImage: image!)
                            .resizable()
                            .scaledToFill()
                    }
                    if showDarkOverlay {
                        Color.black
                    }
                    if !appeared {
                        AppColor.tone
                    }
                }
                .padding(.bottom, 180)
                
            
            
            cameraControls
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .background(AppColor.tone)
        
        .overlay(alignment: .topLeading, content: {
            /*
            CircleButton("xmar", action: <#T##() -> Void#>)
            
            AppBtn(symbol: "xmark", style: .toned) {
                AppHaptics.shared.lightImpact()
                display = false
                appeared = false
            }
            .padding(.top,safeAreaInsets.top)
            .padding(.horizontal)
             */
        })
        .colorScheme(.dark)
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                withAnimation {
                    appeared = true
                }
            })
        }
        .onChange(of: viewModel.capturedCIImage) { _, newImage in
                guard image == nil else { return }
                guard let ci = newImage else { return }

                processCIImageAndAssign(ci, exifOrientation: viewModel.capturedOrientation, maxLength: 1512, assignTo: $image)
            
        }
    }
    private var cameraControls: some View {
        let gridColumns = Array(repeating: GridItem(.flexible()), count: 3)
        
        return LazyVGrid(columns: gridColumns, spacing: 16) {
            
            CapsuleButton("xmark", "Discard") {
                if image != nil {
                        // Discard image only
                    viewModel.capturedCIImage = nil
                    image = nil
                    
                    print("Image after discard: \(String(describing: image))")
                        //
                    } else {
                        // Close session + dismiss
                       // viewModel.session.stopRunning()
                        display = false
                        appeared = false
                    }
            }
            .symbolRenderingMode(.hierarchical)
            .opacity(image == nil ? 0.35 : 1.0)

            Button {
                
                guard image == nil else { return }
                
                Task {
                    showDarkOverlay = true
                    try? await Task.sleep(nanoseconds: 90_000_000)
                    showDarkOverlay = false
                }
                AppHaptics.light()
                viewModel.takePhoto()
            } label: { }
            .buttonStyle(CameraButton())

            CapsuleButton("checkmark", "Select")  {
                if image != nil {
                    AppHaptics.light()
                    viewModel.session.stopRunning()
                    image = nil
                    viewModel.capturedCIImage = nil
                    display = false
                    appeared = false
                }
            }
            .symbolRenderingMode(.hierarchical)
            .opacity(image == nil ? 0.35 : 1.0)
        }
        .foregroundStyle(AppColor.primary)
        .fontWeight(.medium)
        .padding(.horizontal)
        .padding(.top, 32)
        .padding(.bottom, 32 + AppSafeArea.edges.bottom)
        .background(AppColor.tone)
    }


    @Observable
    final class CameraViewModel: NSObject, AVCapturePhotoCaptureDelegate {
        let session = AVCaptureSession()
        private let photoOutput = AVCapturePhotoOutput()
        private var deviceInput: AVCaptureDeviceInput?

        var capturedCIImage: CIImage?
        var capturedOrientation: Int32 = 1

        override init() {
            super.init()
            configure()
        }

        private func configure() {
            Task {
                await MainActor.run {
                    session.beginConfiguration()
                    defer { session.commitConfiguration() }

                    guard let device = AVCaptureDevice.default(for: .video),
                          let input = try? AVCaptureDeviceInput(device: device),
                          session.canAddInput(input) else {
                        print("No video device.")
                        return
                    }

                    session.addInput(input)
                    self.deviceInput = input

                    if session.canAddOutput(photoOutput) {
                        session.addOutput(photoOutput)
                    }

                    session.sessionPreset = .photo
                    
                }
                session.startRunning()
            }
            
        }

        func takePhoto() {
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off
            settings.photoQualityPrioritization = .speed
            photoOutput.capturePhoto(with: settings, delegate: self)
        }

        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let data = photo.fileDataRepresentation(),
                  let ciImage = CIImage(data: data) else { return }

            let orientation = photo.metadata[kCGImagePropertyOrientation as String] as? Int32 ?? 1
            self.capturedCIImage = ciImage
            self.capturedOrientation = orientation
        }
    }
    struct CameraPreview: UIViewRepresentable {
        let session: AVCaptureSession

        func makeUIView(context: Context) -> VideoPreviewView {
            let view = VideoPreviewView()
            view.videoPreviewLayer.session = session
            view.videoPreviewLayer.videoGravity = .resizeAspectFill
            return view
        }

        func updateUIView(_ uiView: VideoPreviewView, context: Context) {}

        final class VideoPreviewView: UIView {
            override class var layerClass: AnyClass {
                AVCaptureVideoPreviewLayer.self
            }

            var videoPreviewLayer: AVCaptureVideoPreviewLayer {
                layer as! AVCaptureVideoPreviewLayer
            }
        }
    }
    struct CameraButton: ButtonStyle{
        func makeBody(configuration: Configuration) -> some View {
            Circle()
                .fill(AppColor.tone)
                .stroke(AppColor.primary.opacity(0.85), lineWidth: 6)
                .frame(width: 62,height: 62)
                .overlay {
                    Circle()
                        .fill(AppColor.primary.opacity(0.85))
                        .shadow(radius: 15)
                        .scaleEffect(configuration.isPressed ? 0.6 : 0.8)
                }
                .clipShape(Circle())
                .animation(.default.speed(2.0), value: configuration.isPressed)
        }
    }
    func processCIImageAndAssign(
        _ ciImage: CIImage,
        exifOrientation: Int32,
        maxLength: CGFloat,
        compressionQuality: CGFloat = 0.75,
        assignTo binding: Binding<UIImage?>
    ) {
        print("Processing image into assignTo… NOT TASK")
        Task(priority: .userInitiated) {
            print("Processing image into assignTo… TASK")
            let start = Date()
            let context = CIContext()

            // Apply correct orientation
            let oriented = ciImage.oriented(forExifOrientation: exifOrientation)

            let extent = oriented.extent
            let width = extent.width
            let height = extent.height

            // Scale to fit maxLength
            let maxSide = max(width, height)
            let scale = maxSide > maxLength ? maxLength / maxSide : 1.0
            let outputSize = CGSize(width: width * scale, height: height * scale)

            // Render at scaled size using CoreGraphics (to respect orientation fully)
            guard let cgImage = context.createCGImage(oriented, from: extent) else { return }

            let renderer = UIGraphicsImageRenderer(size: outputSize)
            let finalImage = renderer.image { _ in
                UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: outputSize))
            }

            guard let data = finalImage.jpegData(compressionQuality: compressionQuality),
                  let result = UIImage(data: data) else { return }

            await MainActor.run {
                binding.wrappedValue = result
            }

            let duration = Date().timeIntervalSince(start)
#if DEBUG
            print("✅ processCIImageAndAssign completed in \(String(format: "%.3f", duration))s")
#endif
        }
    }
}







#if DEBUG

struct CameraView_PreviewWrapper: View {
    @State private var image: UIImage?
    var body: some View {
        CameraView(image: $image, aspectRatio: 4/3, display: .constant(true))
            .ignoresSafeArea(.all)
    }
}

#Preview{
    CameraView_PreviewWrapper()
}


#endif
