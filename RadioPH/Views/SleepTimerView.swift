import SwiftUI

struct SleepTimerView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach([15, 30, 45, 60], id: \.self) { minutes in
                    Button {
                        model.setSleepTimer(minutes: minutes)
                        dismiss()
                    } label: {
                        HStack {
                            Text("\(minutes) minutes")
                            Spacer()
                            Image(systemName: "moon.zzz")
                        }
                    }
                }
                Button("Turn timer off", role: .destructive) {
                    model.cancelSleepTimer()
                    dismiss()
                }
            }
            .navigationTitle("Sleep Timer")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .tint(Theme.brass)
    }
}
