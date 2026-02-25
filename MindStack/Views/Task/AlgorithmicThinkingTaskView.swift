import SwiftUI

struct AlgorithmicThinkingTaskView: View {
    let onFinish: (TaskResult) -> Void

    @State private var blocks: [LogicBlock] = LogicBlock.sample
    @State private var editMode: EditMode = .active
    @State private var showHint = false

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Algoritmik Düşünme")
                            .font(AppTypography.font(30, weight: .heavy))
                            .foregroundColor(.white)
                            .padding(.top, 12)

                        Text("Mantık bloklarını doğru çalışma sırasına göre diz.")
                            .font(AppTypography.font(13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)

                        scenarioCard

                        VStack(spacing: 10) {
                            List {
                                ForEach(blocks) { block in
                                    LogicRow(block: block)
                                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                                        .listRowBackground(Color.clear)
                                }
                                .onMove(perform: move)
                            }
                            .frame(minHeight: 360)
                            .scrollContentBackground(.hidden)
                            .listStyle(.plain)
                            .environment(\.editMode, $editMode)
                            .disabled(false)
                        }

                        Spacer(minLength: 140)
                    }
                    .padding(.horizontal, 18)
                }

                bottomBar
            }

            if showHint {
                Text("Sıra Güncellendi")
                    .font(AppTypography.font(12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(Color.black.opacity(0.35), in: Capsule(style: .continuous))
                    .overlay(Capsule(style: .continuous).stroke(AppColors.primary.opacity(0.18), lineWidth: 1))
                    .transition(.opacity)
                    .padding(.bottom, 86)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .allowsHitTesting(false)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Text("MANTIK SEVİYE 3")
                    .font(AppTypography.font(11, weight: .bold))
                    .tracking(2.4)
                    .foregroundColor(AppColors.textTertiary)
                Spacer()
            }
            .padding(.horizontal, 18)

            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { idx in
                    Capsule(style: .continuous)
                        .fill(idx < 3 ? AppColors.primary : Color.white.opacity(0.16))
                        .frame(height: 6)
                        .glow(idx < 3 ? AppColors.primary : .clear, radius: 8)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 4)
        }
        .padding(.top, 14)
        .background(Color.black.opacity(0.12))
    }

    private var scenarioCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text("SENARYO")
                    .font(AppTypography.font(11, weight: .bold))
                    .tracking(2.2)
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.12), in: Capsule(style: .continuous))
                Divider().overlay(Color.white.opacity(0.10))
            }

            Text("ATM Nakit Çekim")
                .font(AppTypography.font(18, weight: .bold))
                .foregroundColor(.white)

            Text("Bir ATM sistemi için backend mantığını tasarlıyorsun. Bir kullanıcıyı güvenli biçimde doğrulayıp nakit vermek için adımları sırala. Önce güvenliği düşün!")
                .font(AppTypography.font(13, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(3)
        }
        .padding(16)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            Button {
                submit()
            } label: {
                HStack(spacing: 10) {
                    Text("Cevabı Kontrol Et")
                        .font(AppTypography.font(18, weight: .heavy))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundColor(Color(hex: "#001216"))
                .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .glow(AppColors.primary, radius: 18)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 12)
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.35)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    private func move(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
        withAnimation(.easeInOut(duration: 0.2)) {
            showHint = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showHint = false
            }
        }
    }

    private func submit() {
        let correct = LogicBlock.correctOrder
        let current = blocks.map(\.id)
        let ok = current == correct

        let result = TaskResult(
            title: ok ? "Harika düşünce!" : "Az kaldı",
            subtitle: ok ? "Mantığı mükemmel sıraladın." : "Daha güvenli bir sıra dene.",
            xpEarned: ok ? 45 : 15,
            streak: 12,
            explanation: "Önce doğrula, sonra bakiyeyi kontrol et, ardından hesabı düş, nakit ver ve en son kartı çıkar. Bu sıra, kontroller geçmeden yan etki üretmediği için daha güvenlidir.",
            codeSnippet: """
            if pinIsValid {
              if balance >= amount {
                debitAccount(amount)
                dispenseCash(amount)
              }
            }
            ejectCard()
            """
        )
        onFinish(result)
    }
}

private struct LogicRow: View {
    let block: LogicBlock

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.white.opacity(0.28))

            Text(block.text)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.white.opacity(0.90))

            Spacer()

            Text("\(block.index)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.30))
                .frame(width: 28, height: 28)
                .background(Color.white.opacity(0.06), in: Circle())
        }
        .padding(14)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct LogicBlock: Identifiable, Equatable {
    let id: UUID
    let text: String
    let index: Int

    static let sample: [LogicBlock] = [
        .init(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, text: "if (PIN_is_valid)", index: 1),
        .init(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, text: "check_balance(account) > amount", index: 2),
        .init(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, text: "debit_account(amount)", index: 3),
        .init(id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!, text: "dispense_cash(amount)", index: 4),
        .init(id: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!, text: "eject_card()", index: 5)
    ]

    static let correctOrder: [UUID] = sample.map(\.id)
}
