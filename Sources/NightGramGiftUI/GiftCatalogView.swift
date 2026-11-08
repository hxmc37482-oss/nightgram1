#if canImport(SwiftUI)
import SwiftUI
import NightGramGiftEngine

/// Catalogue picker for creating local demo gifts. The host app supplies persistence actions.
public struct GiftCatalogView: View {
    private let onAdd: (GiftTemplate) -> Void

    public init(onAdd: @escaping (GiftTemplate) -> Void) {
        self.onAdd = onAdd
    }

    public var body: some View {
        List(GiftCatalog.all) { template in
            HStack(spacing: 12) {
                Image(systemName: "gift.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text(template.title).font(.body.weight(.medium))
                    Text("\(template.rarity.rawValue.capitalized) · \(template.suggestedVisualValue) demo points")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Add") { onAdd(template) }
                    .buttonStyle(.bordered)
            }
            .padding(.vertical, 4)
        }
        .safeAreaInset(edge: .top) {
            Label("Local demo catalogue — no real Telegram gifts", systemImage: "info.circle")
                .font(.caption.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(.orange.opacity(0.12))
        }
        .navigationTitle("Gift catalogue")
    }
}
#endif
