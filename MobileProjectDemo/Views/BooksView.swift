//
//  MainPageView.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 3/10/23.
//

import SwiftUI

struct BooksView: View {
    @EnvironmentObject var auth: Auth
    @ObservedObject var booksVM: BooksVM
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            TitleView("Περιοδικά")
            Spacer()
            ScrollView {
                ForEach(booksVM.groupedBooks.keys.sorted(), id: \.self) { key in
                    Section(header:
                        HStack {
                            Text(key).bold()
                            Spacer()
                        }.padding(.leading, 20))
                    {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(booksVM.groupedBooks[key]!, id: \.title) { book in
                                VStack {
                                    ZStack(alignment: .bottom) {
                                        AsyncImage(url: URL(string: book.secureImageUrl)) { image in
                                            image.resizable()
                                        } placeholder: { Color.gray }
                                        .frame(width: 130, height: 170)
                                        Text(downloadStateText(for: book))
                                            .font(.title3)
                                            .foregroundStyle(downloadStateColor(for: book))
                                            .padding(3)
                                            .background(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(.white)
                                            )
                                            .padding(5)
                                    }
                                    Text(book.title)
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                }.onTapGesture{ booksVM.downloadPDF(for: book) }
                                    .sheet(isPresented: $booksVM.isSavePresented){
                                        ActivityViewController(activityItems: [booksVM.pdfData!])
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color("dark"))
        .onAppear() { Task { booksVM.fetchBooks } }
    }
    
    func downloadStateText(for book: Book) -> String {
        let state = booksVM.bookDownloadStates[book.id] ?? .pending
        switch state {
        case .pending:
            return "Pending"
        case .inProgress:
            return "Downloading"
        case .completed:
            return "Downloaded"
        }
    }

    func downloadStateColor(for book: Book) -> Color {
        let state = booksVM.bookDownloadStates[book.id] ?? .pending
        switch state {
        case .pending:
            return .red
        case .inProgress:
            return .orange
        case .completed:
            return .green
        }
    }
}

























struct Main_Preview: PreviewProvider {
    static var auth = Auth()
    
    static var previews: some View {
        let booksVM = BooksVM(auth: auth)
        BooksView(booksVM: booksVM)
            .environmentObject(auth)
    }
}


