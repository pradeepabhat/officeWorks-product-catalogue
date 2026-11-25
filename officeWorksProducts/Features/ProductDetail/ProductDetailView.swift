import SwiftUI

struct ProductDetailView: View {
    @State var viewModel: ProductDetailViewModel
    @State private var showEnquiry = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: viewModel.product.imageURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.15)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .padding()
                .background(Color.white, in: RoundedRectangle(cornerRadius: 16))

                Text(viewModel.product.category.capitalized)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.12), in: Capsule())

                Text(viewModel.product.name)
                    .font(.title3.weight(.bold))

                Text(viewModel.product.formattedPrice)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.accentColor)

                if let message = viewModel.errorMessage {
                    Text(message).font(.footnote).foregroundStyle(.red)
                }

                if !viewModel.product.description.isEmpty {
                    Text("Description").font(.headline)
                    Text(viewModel.product.description)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            Button { showEnquiry = true } label: {
                Text("Enquire").font(.headline).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
            .background(.bar)
        }
        .sheet(isPresented: $showEnquiry) {
            EnquiryFormView(productName: viewModel.product.name)
        }
        .overlay { if viewModel.isLoading { ProgressView() } }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}
