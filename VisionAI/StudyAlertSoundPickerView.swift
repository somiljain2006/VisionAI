import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct StudyAlertSoundPickerView: View {
    @AppStorage("studyAlertSound") private var selectedSoundId: String = "bell"
    @State private var previewPlayer: AVAudioPlayer?
    @State private var showFileImporter = false

    var body: some View {
        List {
            ForEach(studyAlertSounds) { sound in
                soundRow(sound)
            }

            HStack {
                Text("Custom Sound")
                Spacer()
                if selectedSoundId == StudyAlertStorage.customSoundId {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showFileImporter = true
            }
        }
        .navigationTitle("Alert Sound")
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.wav, .mp3, .mpeg4Audio],
            allowsMultipleSelection: false
        ) { result in
            guard let url = try? result.get().first else { return }
            importCustomSound(from: url)
        }
    }

    private func playPreview(_ file: String) {
        previewPlayer?.stop()
        guard let url = Bundle.main.url(forResource: file, withExtension: "wav") else { return }
        previewPlayer = try? AVAudioPlayer(contentsOf: url)
        previewPlayer?.play()
    }

    private func playPreview(url: URL) {
        previewPlayer?.stop()
        previewPlayer = try? AVAudioPlayer(contentsOf: url)
        previewPlayer?.play()
    }

    private func soundRow(_ sound: StudyAlertSound) -> some View {
        HStack {
            Text(sound.title)
            Spacer()
            if selectedSoundId == sound.id {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedSoundId = sound.id
            if let file = sound.fileName {
                playPreview(file)
            }
        }
    }

    private func importCustomSound(from sourceURL: URL) {
        guard sourceURL.startAccessingSecurityScopedResource() else {
            print("❌ Cannot access selected file")
            return
        }
        defer { sourceURL.stopAccessingSecurityScopedResource() }

        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let ext = sourceURL.pathExtension.isEmpty ? "m4a" : sourceURL.pathExtension
        let destination = docs.appendingPathComponent("study_custom_alert.\(ext)")

        do {
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }

            try FileManager.default.copyItem(at: sourceURL, to: destination)

            StudyAlertStorage.customSoundURL = destination
            selectedSoundId = StudyAlertStorage.customSoundId

            playPreview(url: destination)

            print("✅ Custom sound saved:", destination)

        } catch {
            print("❌ Failed to import sound:", error)
        }
    }
}
