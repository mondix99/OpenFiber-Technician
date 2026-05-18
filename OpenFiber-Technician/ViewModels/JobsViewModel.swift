import Foundation
import CoreLocation
internal import Combine
import SwiftUI

@MainActor
final class JobsViewModel: ObservableObject {

    @Published var currentTeam: Team?
    @Published var jobs: [Job] = []
    @Published var selectedJob: Job?

    init() {
        loadMockJobs()
    }

    func job(withId id: UUID) -> Job? {
        jobs.first { $0.id == id }
    }

    func step(jobId: UUID, sectionId: UUID, stepId: UUID) -> JobStep? {
        guard let job = job(withId: jobId),
              let section = job.sections.first(where: { $0.id == sectionId })
        else { return nil }
        return section.steps.first { $0.id == stepId }
    }

    func step(jobId: UUID, stepId: UUID) -> JobStep? {
        guard let job = job(withId: jobId) else { return nil }
        for section in job.sections {
            if let step = section.steps.first(where: { $0.id == stepId }) {
                return step
            }
        }
        return nil
    }

    func bindingForJobSections(jobId: UUID) -> Binding<[JobSection]>? {
        guard let idx = jobs.firstIndex(where: { $0.id == jobId }) else { return nil }
        return Binding(
            get: { self.jobs[idx].sections },
            set: { self.jobs[idx].sections = $0 }
        )
    }

    func updateStepValue(jobId: UUID, sectionId: UUID, stepId: UUID, value: StepValue) {
        guard let ji = jobs.firstIndex(where: { $0.id == jobId }),
              let si = jobs[ji].sections.firstIndex(where: { $0.id == sectionId }),
              let ti = jobs[ji].sections[si].steps.firstIndex(where: { $0.id == stepId })
        else { return }
        jobs[ji].sections[si].steps[ti].value = value
    }

    func updateStepValue(jobId: UUID, stepId: UUID, value: StepValue) {
        guard let indices = indicesForStep(jobId: jobId, stepId: stepId) else { return }
        jobs[indices.jobIndex].sections[indices.sectionIndex].steps[indices.stepIndex].value = value
    }

    func updateStepStatus(jobId: UUID, sectionId: UUID, stepId: UUID, status: StepStatus) {
        guard let ji = jobs.firstIndex(where: { $0.id == jobId }),
              let si = jobs[ji].sections.firstIndex(where: { $0.id == sectionId }),
              let ti = jobs[ji].sections[si].steps.firstIndex(where: { $0.id == stepId })
        else { return }
        jobs[ji].sections[si].steps[ti].status = status
    }

    func updateStepStatus(jobId: UUID, stepId: UUID, status: StepStatus) {
        guard let indices = indicesForStep(jobId: jobId, stepId: stepId) else { return }
        jobs[indices.jobIndex].sections[indices.sectionIndex].steps[indices.stepIndex].status = status
    }

    func stepBinding(jobId: UUID, sectionId: UUID, stepId: UUID) -> Binding<JobStep>? {
        guard let ji = jobs.firstIndex(where: { $0.id == jobId }),
              let si = jobs[ji].sections.firstIndex(where: { $0.id == sectionId }),
              let ti = jobs[ji].sections[si].steps.firstIndex(where: { $0.id == stepId })
        else { return nil }

        return Binding(
            get: { self.jobs[ji].sections[si].steps[ti] },
            set: { self.jobs[ji].sections[si].steps[ti] = $0 }
        )
    }

    func toggleSection(jobId: UUID, sectionId: UUID) {
        guard let ji = jobs.firstIndex(where: { $0.id == jobId }),
              let si = jobs[ji].sections.firstIndex(where: { $0.id == sectionId })
        else { return }
        let willExpand = !jobs[ji].sections[si].isExpanded
        if willExpand {
            for i in jobs[ji].sections.indices {
                jobs[ji].sections[i].isExpanded = i == si
            }
        } else {
            jobs[ji].sections[si].isExpanded = false
        }
    }

    func stringValueBinding(jobId: UUID, sectionId: UUID, stepId: UUID) -> Binding<String> {
        Binding(
            get: {
                guard let s = self.step(jobId: jobId, sectionId: sectionId, stepId: stepId) else { return "" }
                if case .string(let v) = s.value { return v }
                return ""
            },
            set: { self.updateStepValue(jobId: jobId, sectionId: sectionId, stepId: stepId, value: .string($0)) }
        )
    }

    func boolValueBinding(jobId: UUID, sectionId: UUID, stepId: UUID) -> Binding<Bool> {
        Binding(
            get: {
                guard let s = self.step(jobId: jobId, sectionId: sectionId, stepId: stepId) else { return false }
                if case .bool(let v) = s.value { return v }
                return false
            },
            set: { self.updateStepValue(jobId: jobId, sectionId: sectionId, stepId: stepId, value: .bool($0)) }
        )
    }

    func dateValueBinding(jobId: UUID, sectionId: UUID, stepId: UUID) -> Binding<Date> {
        Binding(
            get: {
                guard let s = self.step(jobId: jobId, sectionId: sectionId, stepId: stepId) else { return Date() }
                if case .date(let d) = s.value { return d }
                return Date()
            },
            set: { self.updateStepValue(jobId: jobId, sectionId: sectionId, stepId: stepId, value: .date($0)) }
        )
    }

    func dropdownSelectionBinding(jobId: UUID, sectionId: UUID, stepId: UUID) -> Binding<String> {
        Binding(
            get: {
                guard let s = self.step(jobId: jobId, sectionId: sectionId, stepId: stepId) else { return "" }
                guard !s.options.isEmpty else { return "" }
                if case .string(let v) = s.value, s.options.contains(v) { return v }
                return ""
            },
            set: { new in
                if new.isEmpty {
                    self.updateStepValue(jobId: jobId, sectionId: sectionId, stepId: stepId, value: .none)
                } else {
                    self.updateStepValue(jobId: jobId, sectionId: sectionId, stepId: stepId, value: .string(new))
                }
            }
        )
    }

    func applyNumberFieldText(jobId: UUID, sectionId: UUID, stepId: UUID, text: String) {
        let t = text.trimmingCharacters(in: .whitespaces)
        if t.isEmpty {
            updateStepValue(jobId: jobId, sectionId: sectionId, stepId: stepId, value: .none)
            return
        }
        if let v = Double(t.replacingOccurrences(of: ",", with: ".")) {
            updateStepValue(jobId: jobId, sectionId: sectionId, stepId: stepId, value: .number(v))
        }
    }

    func numberFieldString(jobId: UUID, sectionId: UUID, stepId: UUID) -> String {
        guard let s = step(jobId: jobId, sectionId: sectionId, stepId: stepId) else { return "" }
        if case .number(let n) = s.value { return Self.formatNumberForField(n) }
        return ""
    }

    @discardableResult
    func saveStep(jobId: UUID, stepId: UUID) -> Bool {
        guard let job = job(withId: jobId),
              let step = step(jobId: jobId, stepId: stepId)
        else { return false }

        let ok = Self.valuePassesValidation(step: step, job: job)
        updateStepStatus(jobId: jobId, stepId: stepId, status: ok ? .completed : .failed)
        return ok
    }

    func saveStep(jobId: UUID, sectionId: UUID, stepId: UUID) {
        _ = saveStep(jobId: jobId, stepId: stepId)
    }

    func updateNotes(jobId: UUID, value: String?) {
        guard let idx = jobs.firstIndex(where: { $0.id == jobId }) else { return }
        jobs[idx].notes = value
    }

    func notesBinding(jobId: UUID) -> Binding<String> {
        Binding(
            get: { self.job(withId: jobId)?.notes ?? "" },
            set: { new in
                self.updateNotes(jobId: jobId, value: new.isEmpty ? nil : new)
            }
        )
    }

    func stepValidationPasses(jobId: UUID, sectionId: UUID, stepId: UUID) -> Bool {
        guard let job = job(withId: jobId),
              let step = step(jobId: jobId, sectionId: sectionId, stepId: stepId)
        else { return false }
        return Self.valuePassesValidation(step: step, job: job)
    }

    func performSimulatedScan(jobId: UUID, sectionId: UUID, stepId: UUID) {
        guard let ji = jobs.firstIndex(where: { $0.id == jobId }),
              let si = jobs[ji].sections.firstIndex(where: { $0.id == sectionId }),
              let ti = jobs[ji].sections[si].steps.firstIndex(where: { $0.id == stepId })
        else { return }

        let stepSnapshot = jobs[ji].sections[si].steps[ti]
        guard stepSnapshot.type == .scan else { return }

        let jobSnapshot = jobs[ji]
        let expectedSerial: String? = stepSnapshot.scanCompareDeviceId.flatMap { did in
            jobSnapshot.devices.first(where: { $0.id == did })?.serialNumber
        }

        if let expected = expectedSerial {
            let wrongSerial = "SN-\(Int.random(in: 100_000...999_999))"
            let generated = Bool.random() ? expected : wrongSerial
            let didMatch = generated == expected
            jobs[ji].sections[si].steps[ti].value = .string(generated)
            if didMatch {
                jobs[ji].sections[si].steps[ti].status = .completed
                if let did = stepSnapshot.scanCompareDeviceId {
                    verifyDevice(jobId: jobId, deviceId: did)
                }
            } else {
                jobs[ji].sections[si].steps[ti].status = .failed
            }
        } else {
            let generated = "ONT123456"
            jobs[ji].sections[si].steps[ti].value = .string(generated)
            jobs[ji].sections[si].steps[ti].status = .completed
        }
    }

    func simulateImageCapture(jobId: UUID, sectionId: UUID, stepId: UUID) {
        updateStepValue(jobId: jobId, sectionId: sectionId, stepId: stepId, value: .string("IMG_SIM_\(UUID().uuidString.prefix(8))"))
    }

    func simulateLocation(jobId: UUID, sectionId: UUID, stepId: UUID) {
        updateStepValue(jobId: jobId, sectionId: sectionId, stepId: stepId, value: .string("45.1847, 9.1582"))
    }

    func hasFailedSteps(for jobId: UUID) -> Bool {
        guard let job = job(withId: jobId) else { return false }
        return job.sections.flatMap(\.steps).contains { $0.status == .failed }
    }

    func allStepsCompleted(for jobId: UUID) -> Bool {
        guard let job = job(withId: jobId) else { return false }
        let steps = job.sections
            .flatMap(\.steps)
            .filter { !$0.title.lowercased().contains("allegati") }
        let allNonAttachmentStepsCompleted = !steps.isEmpty && steps.allSatisfy { $0.status == .completed }
        return allNonAttachmentStepsCompleted && job.isCheckedIn
    }

    func allStepsCompleted(jobId: UUID) -> Bool {
        allStepsCompleted(for: jobId)
    }

    func canFinalizeJob(jobId: UUID) -> Bool {
        allStepsCompleted(for: jobId) && !hasFailedSteps(for: jobId)
    }

    func completedStepsCount(for jobId: UUID) -> Int {
        guard let job = job(withId: jobId) else { return 0 }
        return job.sections.flatMap(\.steps).filter { $0.status == .completed }.count
    }

    func totalStepsCount(for jobId: UUID) -> Int {
        guard let job = job(withId: jobId) else { return 0 }
        return job.sections.flatMap(\.steps).count
    }

    func checklistProgress(for jobId: UUID) -> (completed: Int, total: Int) {
        (completedStepsCount(for: jobId), totalStepsCount(for: jobId))
    }

    func loadMockJobs() {
        let installationDeviceId = UUID()
        let repairDeviceId = UUID()

        jobs = [
            Job(
                id: UUID(),
                customerName: "Mario Rossi",
                address: "Via Roma 12, Pavia",
                popZone: "POP-01",
                appointmentTime: Date(),
                status: .new,
                jobType: .installation,
                devices: [
                    Device(
                        id: installationDeviceId,
                        name: "ONT Huawei",
                        serialNumber: "ONT123456",
                        type: .ont,
                        isVerified: false
                    )
                ],
                sections: installationSectionsSample(scanDeviceId: installationDeviceId),
                infoSections: [
                    JobInfoSection(
                        title: "Intervento",
                        fields: [
                            JobInfoField(title: "Tipo", value: "Nuova attivazione FTTH"),
                            JobInfoField(title: "Slot", value: "Mattina"),
                            JobInfoField(title: "Priorita", value: "Alta")
                        ]
                    ),
                    JobInfoSection(
                        title: "OLO",
                        fields: [
                            JobInfoField(title: "Operatore", value: "Open Fiber Wholesale"),
                            JobInfoField(title: "Codice ordine", value: "OF-INS-10294")
                        ]
                    ),
                    JobInfoSection(
                        title: "Dati riferimento",
                        fields: [
                            JobInfoField(title: "Cliente", value: "Mario Rossi"),
                            JobInfoField(title: "Telefono", value: "+39 340 0000000"),
                            JobInfoField(title: "Service ID", value: "FTTH-PV-10294")
                        ]
                    )
                ],
                attachments: [],
                latitude: 45.1847,
                longitude: 9.1582,
                notes: "Morning visit — buzzer \"Rossi\".",
                assignedTechnicianId: nil,
                assignedTeamId: "teamA"
            ),

            Job(
                id: UUID(),
                customerName: "Giulia Bianchi",
                address: "Corso Garibaldi 8, Pavia",
                popZone: "POP-02",
                appointmentTime: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
                status: .new,
                jobType: .repair,
                devices: [
                    Device(
                        id: repairDeviceId,
                        name: "Router TP-Link",
                        serialNumber: "RTR987654",
                        type: .router,
                        isVerified: false
                    )
                ],
                sections: repairSectionsSample(scanDeviceId: repairDeviceId),
                infoSections: [
                    JobInfoSection(
                        title: "Intervento",
                        fields: [
                            JobInfoField(title: "Tipo", value: "Guasto linea"),
                            JobInfoField(title: "Ticket", value: "REP-8831")
                        ]
                    ),
                    JobInfoSection(
                        title: "OLO",
                        fields: [
                            JobInfoField(title: "Operatore", value: "Open Fiber Wholesale"),
                            JobInfoField(title: "Codice guasto", value: "GF-8831")
                        ]
                    ),
                    JobInfoSection(
                        title: "Dati riferimento",
                        fields: [
                            JobInfoField(title: "Cliente", value: "Giulia Bianchi"),
                            JobInfoField(title: "Telefono", value: "+39 347 1112233")
                        ]
                    )
                ],
                attachments: [],
                latitude: 45.1901,
                longitude: 9.1603,
                notes: "Customer reported intermittent connection.",
                assignedTechnicianId: nil,
                assignedTeamId: "teamB"
            )
        ]
    }

    private func installationSectionsSample(scanDeviceId: UUID) -> [JobSection] {
        var sections: [JobSection] = [
            JobSection(
                title: "Execution",
                steps: [
                    JobStep(title: "Check-in", subtitle: "", type: .location, status: .pending, value: .none),
                    JobStep(title: "Utilizzo Adduzione TIM", subtitle: "", type: .boolean, status: .pending, value: .bool(false)),
                    JobStep(title: "Esito", subtitle: "", type: .dropdown, status: .pending, value: .none, options: ["Positivo", "Negativo"]),
                    JobStep(title: "Collegamento FO", subtitle: "", type: .text, status: .pending, value: .none),
                    JobStep(title: "Collaudo Linea", subtitle: "", type: .scan, status: .pending, value: .none, options: [], scanCompareDeviceId: scanDeviceId),
                    JobStep(title: "Firma Tecnico", subtitle: "", type: .image, status: .pending, value: .none),
                    JobStep(title: "Verbale Intervento", subtitle: "", type: .text, status: .pending, value: .none),
                    JobStep(title: "Firma Verbale", subtitle: "", type: .image, status: .pending, value: .none),
                    JobStep(title: "Allegati", subtitle: "", type: .image, status: .pending, value: .none),
                    JobStep(title: "SRD", subtitle: "", type: .text, status: .pending, value: .none),
                    JobStep(title: "Help Desk", subtitle: "", type: .text, status: .pending, value: .none)
                ],
                isExpanded: true
            )
        ]
        applyDefaultSectionExpansion(&sections)
        return sections
    }

    private func repairSectionsSample(scanDeviceId: UUID) -> [JobSection] {
        var sections: [JobSection] = [
            JobSection(
                title: "Execution",
                steps: [
                    JobStep(title: "Check-in", subtitle: "", type: .location, status: .pending, value: .none),
                    JobStep(title: "Utilizzo Adduzione TIM", subtitle: "", type: .boolean, status: .pending, value: .bool(false)),
                    JobStep(title: "Esito", subtitle: "", type: .dropdown, status: .pending, value: .none, options: ["Positivo", "Negativo"]),
                    JobStep(title: "Collegamento FO", subtitle: "", type: .text, status: .pending, value: .none),
                    JobStep(title: "Collaudo Linea", subtitle: "", type: .scan, status: .pending, value: .none, options: [], scanCompareDeviceId: scanDeviceId),
                    JobStep(title: "Firma Tecnico", subtitle: "", type: .image, status: .pending, value: .none),
                    JobStep(title: "Verbale Intervento", subtitle: "", type: .text, status: .pending, value: .none),
                    JobStep(title: "Firma Verbale", subtitle: "", type: .image, status: .pending, value: .none),
                    JobStep(title: "Allegati", subtitle: "", type: .image, status: .pending, value: .none),
                    JobStep(title: "SRD", subtitle: "", type: .text, status: .pending, value: .none),
                    JobStep(title: "Help Desk", subtitle: "", type: .text, status: .pending, value: .none)
                ],
                isExpanded: true
            )
        ]
        applyDefaultSectionExpansion(&sections)
        return sections
    }

    private func applyDefaultSectionExpansion(_ sections: inout [JobSection]) {
        for i in sections.indices {
            sections[i].isExpanded = i == 0
        }
    }

    var filteredJobs: [Job] {
        guard let currentTeam else { return [] }
        return jobs.filter { $0.assignedTeamId == currentTeam.id }
    }

    func appendAttachment(jobId: UUID, url: URL) {
        guard let jobIndex = jobs.firstIndex(where: { $0.id == jobId }) else { return }
        jobs[jobIndex].attachments.append(url)
    }

    func setCheckedIn(jobId: UUID, coordinate: CLLocationCoordinate2D) {
        guard let jobIndex = jobs.firstIndex(where: { $0.id == jobId }) else { return }
        jobs[jobIndex].isCheckedIn = true
        jobs[jobIndex].checkInLatitude = coordinate.latitude
        jobs[jobIndex].checkInLongitude = coordinate.longitude
    }

    func performCheckIn(jobId: UUID, coordinate: CLLocationCoordinate2D) {
        setCheckedIn(jobId: jobId, coordinate: coordinate)
        guard let jobIndex = jobs.firstIndex(where: { $0.id == jobId }) else { return }

        if jobs[jobIndex].status == .new || jobs[jobIndex].status == .accepted {
            jobs[jobIndex].status = .traveling
        }

        for sectionIndex in jobs[jobIndex].sections.indices {
            if let stepIndex = jobs[jobIndex].sections[sectionIndex].steps.firstIndex(where: { $0.title.lowercased() == "check-in" }) {
                jobs[jobIndex].sections[sectionIndex].steps[stepIndex].status = .completed
                jobs[jobIndex].sections[sectionIndex].steps[stepIndex].value = .string("\(coordinate.latitude), \(coordinate.longitude)")
                break
            }
        }
    }

    func setTeam(_ team: Team) {
        currentTeam = team
    }

    func updateJobStatus(_ job: Job, status: JobStatus) {
        guard let index = jobs.firstIndex(where: { $0.id == job.id }) else { return }
        jobs[index].status = status
    }

    func acceptJob(_ job: Job) {
        updateJobStatus(job, status: .accepted)
    }

    func startTraveling(_ job: Job) {
        updateJobStatus(job, status: .traveling)
    }

    func startJob(_ job: Job) {
        updateJobStatus(job, status: .working)
    }

    func attachPDF(to job: Job, url: URL) {
        guard let index = jobs.firstIndex(where: { $0.id == job.id }) else { return }
        jobs[index].attachments.append(url)
    }

    func verifyDevice(jobId: UUID, deviceId: UUID) {
        guard let jobIndex = jobs.firstIndex(where: { $0.id == jobId }),
              let deviceIndex = jobs[jobIndex].devices.firstIndex(where: { $0.id == deviceId })
        else { return }
        jobs[jobIndex].devices[deviceIndex].isVerified = true
    }

    func completeJob(jobId: UUID) {
        guard canFinalizeJob(jobId: jobId),
              let index = jobs.firstIndex(where: { $0.id == jobId })
        else { return }
        jobs[index].status = .completed
    }

    private static func valuePassesValidation(step: JobStep, job: Job) -> Bool {
        switch step.type {
        case .text, .image, .location:
            guard case .string(let s) = step.value else { return false }
            return !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .scan:
            guard case .string(let s) = step.value else { return false }
            let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return false }
            if let did = step.scanCompareDeviceId,
               let expected = job.devices.first(where: { $0.id == did })?.serialNumber {
                return trimmed == expected
            }
            return true
        case .number:
            if case .number = step.value { return true }
            return false
        case .dropdown:
            guard case .string(let s) = step.value else { return false }
            let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            return !t.isEmpty && step.options.contains(s)
        case .boolean:
            if case .bool = step.value { return true }
            return false
        case .date:
            if case .date = step.value { return true }
            return false
        }
    }

    private static func formatNumberForField(_ n: Double) -> String {
        let rounded = n.rounded()
        if abs(n - rounded) < 0.000_001 {
            return String(Int(rounded))
        }
        return String(n)
    }

    private func indicesForStep(jobId: UUID, stepId: UUID) -> (jobIndex: Int, sectionIndex: Int, stepIndex: Int)? {
        guard let jobIndex = jobs.firstIndex(where: { $0.id == jobId }) else { return nil }

        for sectionIndex in jobs[jobIndex].sections.indices {
            if let stepIndex = jobs[jobIndex].sections[sectionIndex].steps.firstIndex(where: { $0.id == stepId }) {
                return (jobIndex, sectionIndex, stepIndex)
            }
        }
        return nil
    }
}
