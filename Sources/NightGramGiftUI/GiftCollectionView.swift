#if canImport(SwiftUI)
import SwiftUI
import NightGramGiftEngine

/// A profile-grid preview. Every screen explicitly identifies gifts as local demo items.
public struct GiftCollectionView: View {
    private let gifts: [LocalGift]
    private let columns = [GridItem(.adaptive(minimum: 92), spacing: 12)]

    public init(gifts: [LocalGift]) {
        self.gifts = gifts.filter { !$0.isHidden }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Gifts")
                    .font(.title3.weight(.semibold))
                Spacer()
                Text("LOCAL DEMO")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.orange.opacity(0.15), in: Capsule())
            }

            if gifts.isEmpty {
                ContentUnavailableView("No local gifts", systemImage: "gift", description: Text("Demo gifts added on this device will appear here."))
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(gifts.sorted { $0.isPinned && !$1.isPinned }) { gift in
                        VStack(spacing: 8) {
                            Image(gift.assetName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 54)
                                .frame(maxWidth: .infinity)
                            Text(gift.title)
                                .font(.caption.weight(.medium))
                                .lineLimit(1)
                            Text(gift.rarity.rawValue.capitalized)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            if gift.isPinned { Image(systemName: "pin.fill").font(.caption2) }
                        }
                        .padding(10)
                        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            Text("These items exist only in this app's local storage. They are not Telegram gifts.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}
#endif
