import SwiftUI

struct HomeView: View {
    private let sampleDecks = [
        ("Tech", Color.green),
        ("Movies", Color.blue),
        ("Food", Color.orange),
        ("Sports", Color.purple)
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.07, blue: 0.10),
                    Color(red: 0.10, green: 0.16, blue: 0.22)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    deckPreview
                    deckGrid
                }
                .padding(.horizontal, 24)
                .padding(.top, 36)
                .padding(.bottom, 32)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AppMetadata.displayName)
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .accessibilityIdentifier("appTitle")

            Text(AppMetadata.subtitle)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
        }
    }

    private var deckPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.white.opacity(0.08))
                .frame(height: 190)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(.white.opacity(0.10), lineWidth: 1)
                )

            ZStack {
                tiltedCard(color: .orange, rotation: -16, x: -52, y: 14)
                tiltedCard(color: .purple, rotation: -4, x: 0, y: -2)
                tiltedCard(color: .mint, rotation: 14, x: 54, y: 12)

                Image(systemName: "theatermasks.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(x: 54, y: 12)
                    .rotationEffect(.degrees(14))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Colorful charades deck illustration")
    }

    private var deckGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Decks")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 52, height: 52)
                        .background(Color.yellow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .accessibilityLabel("Create deck")
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(sampleDecks, id: \.0) { deck in
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(deck.1.gradient)
                        .frame(height: 118)
                        .overlay {
                            Text(deck.0)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 2)
                        }
                        .shadow(color: deck.1.opacity(0.22), radius: 10, x: 0, y: 8)
                }
            }
        }
    }

    private func tiltedCard(color: Color, rotation: Double, x: CGFloat, y: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(color.gradient)
            .frame(width: 96, height: 128)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.20), lineWidth: 2)
            )
            .shadow(color: color.opacity(0.25), radius: 8, x: 0, y: 6)
            .rotationEffect(.degrees(rotation))
            .offset(x: x, y: y)
    }
}

#Preview {
    HomeView()
}
