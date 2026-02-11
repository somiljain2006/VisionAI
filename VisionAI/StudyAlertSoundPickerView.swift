import SwiftUI
import AVFoundation

struct StudyAlertSoundPickerView: View {
    @AppStorage("studyAlertSound") private var selectedSoundId: String = "bell"
    @State private var previewPlayer: AVAudioPlayer?

    var body: some View {
        List {
            ForEach(studyAlertSounds) { sound in
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
                    playPreview(sound.fileName)
                }
            }
        }
        .navigationTitle("Study Alert Sound")
    }

    private func playPreview(_ file: String) {
        previewPlayer?.stop()
        guard let url = Bundle.main.url(forResource: file, withExtension: "wav") else { return }
        previewPlayer = try? AVAudioPlayer(contentsOf: url)
        previewPlayer?.play()
    }
}
