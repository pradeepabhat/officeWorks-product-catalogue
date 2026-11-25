import SwiftUI

/// Card for a product; tapping it opens the product details page.
struct ProductCardView: View {
    let product: Product

    var body: some View {
        NavigationLink {
            ProductDetailView(viewModel: ProductDetailViewModel(product: product))
        } label: {
            HStack(spacing: 12) {
                AsyncImage(url: product.imageURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.15)
                }
                .frame(width: 72, height: 72)
                .padding(6)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.subheadline.weight(.semibold))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    Text(product.category.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(product.formattedPrice)
                        .font(.headline)
                        .foregroundStyle(Color.accentColor)
                }
                .foregroundStyle(.primary)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(10)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.primary.opacity(0.08), lineWidth: 1))
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
            .shadow(color: .black.opacity(0.06), radius: 1, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}
