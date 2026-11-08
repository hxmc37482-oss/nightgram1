#if canImport(SwiftUI)
import SwiftUI
import NightGramGiftEngine
#if canImport(UIKit)
import UIKit
#endif

/// A profile-grid preview for gifts stored only in NightGram's local demo database.
public struct GiftCollectionView: View {
    private let gifts: [LocalGift]
    private let columns = [GridItem(.adaptive(minimum: 92), spacing: 12)]

    public init(gifts: [LocalGift]) {
        self.gifts = gifts.filter { !$0.isHidden && $0.soldAt == nil }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Gifts").font(.title3.weight(.semibold))
                Spacer()
                Text("LOCAL DEMO")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.orange.opacity(0.15), in: Capsule())
            }

            if gifts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "gift").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No local gifts").font(.headline)
                    Text("Demo gifts added on this device will appear here.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(gifts.sorted {
                        if $0.isPinned != $1.isPinned { return $0.isPinned }
                        return $0.createdAt > $1.createdAt
                    }) { gift in
                        VStack(spacing: 7) {
                            Group {
                                #if canImport(UIKit)
                                if UIImage(named: gift.assetName) != nil {
                                    Image(gift.assetName).resizable().scaledToFit()
                                } else {
                                    Image(systemName: "gift.fill").resizable().scaledToFit()
                                        .foregroundStyle(.secondary).padding(8)
                                }
                                #else
                                Image(systemName: "gift.fill").resizable().scaledToFit()
                                    .foregroundStyle(.secondary).padding(8)
                                #endif
                            }
                            .frame(height: 54)
                            .frame(maxWidth: .infinity)

                            Text(gift.title)
                                .font(.caption.weight(.medium))
                                .lineLimit(1)

                            Text(gift.rarity.rawValue.capitalized)
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 4) {
                                if gift.isPinned { Image(systemName: "pin.fill") }
                                if gift.isWorn { Text("Носится") }
                                if gift.isReceived { Text("Демо-получен") }
                                if gift.marketPrice != nil { Text("Маркет") }
                            }
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        }
                        .padding(10)
                        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                    }
                }
            }

            Text("These items and their balances exist only in NightGram on this device. They are not Telegram gifts, payments, or account transactions.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}
#endif
