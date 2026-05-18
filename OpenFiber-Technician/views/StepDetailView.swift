import SwiftUI
import UIKit
import CoreLocation

struct StepDetailView: View {
    @Binding var step: JobStep
    let jobId: UUID
    @ObservedObject var viewModel: JobsViewModel

    @State private var locationProvider = StepLocationProvider()
    @State private var textValue: String = ""
    @State private var numberValue: String = ""
    @State private var dropdownValue: String = ""
    @State private var boolValue: Bool = false
    @State private var dateValue: Date = Date()

    @State private var showCamera = false
    @State private var showSignatureScreen = false
    @State private var signaturePoints: [CGPoint] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(step.title)
                    .font(.title2.bold())
                if !step.subtitle.isEmpty {
                    Text(step.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                contentCard
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("Save") {
                    saveStep()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding(16)
        }
        .navigationTitle(step.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: hydrateLocalState)
        .navigationDestination(isPresented: $showSignatureScreen) {
            signatureEditor
                .navigationTitle("Firma Tecnico")
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showCamera) {
            CameraImagePicker { image in
                if let image {
                    handleCapturedImage(image)
                }
            }
        }
    }

    @ViewBuilder
    private var contentCard: some View {
        if isSRDStep {
            placeholderCard(title: "SRD", message: "SRD workflow will be available in a future release.")
        } else if isTechnicianSignatureStep {
            signatureEditor
        } else if isHelpDeskStep {
            placeholderCard(title: "Help Desk", message: "Use this step to contact support when needed.")
        } else if isAttachmentsStep {
            Text("\(attachmentCount) files uploaded")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            inputByStepType
        }
    }

    @ViewBuilder
    private var inputByStepType: some View {
        switch step.type {
        case .text:
            TextField("Insert text", text: $textValue)
                .textFieldStyle(.roundedBorder)
        case .number:
            TextField("Insert number", text: $numberValue)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
        case .dropdown:
            Picker("Selection", selection: $dropdownValue) {
                Text("Select option").tag("")
                ForEach(step.options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
        case .boolean:
            Toggle("Yes / No", isOn: $boolValue)
        case .image:
            Button("Open Camera") {
                showCamera = true
            }
            .buttonStyle(.bordered)
        case .scan:
            VStack(alignment: .leading, spacing: 10) {
                Button("Simulate QR Scan") {
                    let fake = "QR-\(UUID().uuidString.prefix(8).uppercased())"
                    step.value = .string(fake)
                }
                .buttonStyle(.bordered)
                if case .string(let value) = step.value, !value.isEmpty {
                    Text(value)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        case .date:
            DatePicker("Date", selection: $dateValue, displayedComponents: .date)
                .datePickerStyle(.compact)
        case .location:
            VStack(alignment: .leading, spacing: 10) {
                Button("Fetch current GPS") {
                    locationProvider.requestCurrentLocation { coordinate in
                        step.value = .string("\(coordinate.latitude), \(coordinate.longitude)")
                    }
                }
                .buttonStyle(.bordered)
                if case .string(let value) = step.value, !value.isEmpty {
                    Text(value)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var signatureEditor: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Draw signature below")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.12))
                    .frame(height: 180)
                Path { path in
                    guard let first = signaturePoints.first else { return }
                    path.move(to: first)
                    for point in signaturePoints.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .stroke(Color.primary, lineWidth: 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        signaturePoints.append(value.location)
                    }
            )
            HStack {
                Button("Clear") {
                    signaturePoints.removeAll()
                }
                .buttonStyle(.bordered)

                Button("Save Signature") {
                    if let image = SignatureRenderer.render(points: signaturePoints, size: CGSize(width: 320, height: 180)) {
                        handleCapturedImage(image)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(signaturePoints.isEmpty)
            }
        }
        .padding(16)
    }

    private func hydrateLocalState() {
        switch step.value {
        case .string(let value):
            textValue = value
            dropdownValue = value
        case .number(let value):
            numberValue = Self.numberFormatter.string(from: NSNumber(value: value)) ?? ""
        case .bool(let value):
            boolValue = value
        case .date(let value):
            dateValue = value
        case .none:
            break
        }
    }

    private func saveStep() {
        if isAttachmentsStep || isSRDStep || isHelpDeskStep {
            viewModel.updateStepStatus(jobId: jobId, stepId: step.id, status: .completed)
            return
        }

        switch step.type {
        case .text:
            let trimmed = textValue.trimmingCharacters(in: .whitespacesAndNewlines)
            viewModel.updateStepValue(jobId: jobId, stepId: step.id, value: .string(trimmed))
        case .number:
            if let number = Double(numberValue.replacingOccurrences(of: ",", with: ".")) {
                viewModel.updateStepValue(jobId: jobId, stepId: step.id, value: .number(number))
            } else {
                viewModel.updateStepValue(jobId: jobId, stepId: step.id, value: .none)
            }
        case .dropdown:
            viewModel.updateStepValue(jobId: jobId, stepId: step.id, value: dropdownValue.isEmpty ? .none : .string(dropdownValue))
        case .boolean:
            viewModel.updateStepValue(jobId: jobId, stepId: step.id, value: .bool(boolValue))
        case .date:
            viewModel.updateStepValue(jobId: jobId, stepId: step.id, value: .date(dateValue))
        case .image, .scan, .location:
            break
        }

        viewModel.updateStepStatus(jobId: jobId, stepId: step.id, status: .completed)
    }

    private func handleCapturedImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let fileName = "attachment-\(UUID().uuidString).jpg"
        let targetURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: targetURL)
            viewModel.appendAttachment(jobId: jobId, url: targetURL)
            viewModel.updateStepValue(jobId: jobId, stepId: step.id, value: .string(fileName))
        } catch {
            return
        }
    }

    private func placeholderCard(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var stepTitleLowercased: String {
        step.title.lowercased()
    }

    private var isTechnicianSignatureStep: Bool {
        stepTitleLowercased.contains("firma tecnico")
    }

    private var isAttachmentsStep: Bool {
        stepTitleLowercased.contains("allegati")
    }

    private var isSRDStep: Bool {
        stepTitleLowercased == "srd"
    }

    private var isHelpDeskStep: Bool {
        stepTitleLowercased.contains("help desk")
    }

    private var attachmentCount: Int {
        viewModel.job(withId: jobId)?.attachments.count ?? 0
    }

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()
}

private struct CameraImagePicker: UIViewControllerRepresentable {
    let onImagePicked: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImagePicked: (UIImage?) -> Void
        let dismiss: DismissAction

        init(onImagePicked: @escaping (UIImage?) -> Void, dismiss: DismissAction) {
            self.onImagePicked = onImagePicked
            self.dismiss = dismiss
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onImagePicked(nil)
            dismiss()
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.originalImage] as? UIImage
            onImagePicked(image)
            dismiss()
        }
    }
}

@MainActor
private final class StepLocationProvider: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    private var onCoordinate: ((CLLocationCoordinate2D) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestCurrentLocation(onCoordinate: @escaping (CLLocationCoordinate2D) -> Void) {
        self.onCoordinate = onCoordinate
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        onCoordinate?(coordinate)
        onCoordinate = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onCoordinate = nil
    }
}

private enum SignatureRenderer {
    static func render(points: [CGPoint], size: CGSize) -> UIImage? {
        guard !points.isEmpty else { return nil }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            UIColor.black.setStroke()
            let path = UIBezierPath()
            path.lineWidth = 2
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.stroke()
        }
    }
}
