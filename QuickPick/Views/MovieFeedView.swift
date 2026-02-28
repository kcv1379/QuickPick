import SwiftUI

//mock domain object for now
struct QPMovie: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let year: String
}

struct MovieFeedView: View {
    //temp states to be changed later
    @State private var timeLimit: String = ""
    @State private var discoveryMode: String = "Popular"
    @State private var showFilterSheet = false
    @State private var page: Int = 1

    let discoveryModes = ["Popular", "Top Rated"]

    //temp mock data
    private let movies: [QPMovie] = [
        .init(title:"Jaws", year:"1975"),
        .init(title:"Before Sunrise", year:"1995"),
        .init(title:"La La Land", year:"2016"),
        .init(title:"Parasite", year:"2019"),
        .init(title:"Interstellar", year:"2014"),
        .init(title:"The Florida Project", year:"2017"),
        .init(title:"Past Lives", year:"2023"),
        .init(title:"Her", year:"2013"),
        .init(title:"Aftersun", year:"2022"),
        .init(title:"Lady Bird", year:"2017"),
        .init(title:"The Social Network", year:"2010"),
        .init(title:"Whiplash", year:"2014"),
        .init(title:"Moonlight", year:"2016"),
        .init(title:"Arrival", year:"2016"),
        .init(title:"Drive", year:"2011"),
        .init(title:"Lost in Translation", year:"2003")
    ]

    //navigation to settings and datails screen once added
    let onOpenSettings: () -> Void
    let onOpenDetails: (_ movieTitle: String) -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        let _ = print("Lifecycle: MovieFeedView onCreate")
        ZStack {
            QPTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        //change to region later
                        Text("\(discoveryMode) • US")
                            .font(.caption)
                            .foregroundStyle(QPTheme.subtle)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(movies) { movie in
                                Button {
                                    // update later
                                    onOpenDetails("\(movie.title) (\(movie.year))")
                                } label: {
                                    // temp text, replace with posters in future
                                    PosterCard(title: movie.title, year: movie.year)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                        .padding(.bottom, 24)
                    }
                }
                bottomBar
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showFilterSheet) {
            filterSheet
                .presentationDetents([.medium])
        }
        .onAppear {
            print("Lifecycle: MovieFeedView onStart")
            print("Lifecycle: MovieFeedView onResume")
        }
        .onDisappear {
            print("Lifecycle: MovieFeedView onPause")
            print("Lifecycle: MovieFeedView onStop")
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("QuickPick")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            //filter button
            Button {
                showFilterSheet = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var bottomBar: some View {
        HStack {

            //settings button
            Button {
                onOpenSettings()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white.opacity(0.9))

            Spacer()

            //prev and next button with paging
            HStack(spacing: 16) {

                Button("Prev") {
                    if page > 1 { page -= 1 }
                    print("Prev page: \(page)")
                }

                Text("Page \(page)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(QPTheme.subtle)
                    .frame(minWidth: 70)

                Button("Next") {
                    // change later
                    page += 1
                    print("Next page: \(page)")
                }
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(QPTheme.bg.opacity(0.98))
    }

    //add additional filters in future
    private var filterSheet: some View {
        ZStack {
            QPTheme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                Text("Filters")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Time limit (minutes)")
                        .font(.caption)
                        .foregroundStyle(QPTheme.subtle)

                    TextField("e.g. 120", text: $timeLimit)
                        .keyboardType(.numberPad)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(QPTheme.field)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Discovery mode")
                        .font(.caption)
                        .foregroundStyle(QPTheme.subtle)

                    Picker("Mode", selection: $discoveryMode) {
                        ForEach(discoveryModes, id: \.self) { m in
                            Text(m).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Button("Apply") {
                    print("Apply filters: timeLimit=\(timeLimit), mode=\(discoveryMode)")
                    showFilterSheet = false
                }
                .buttonStyle(QPPrimaryButtonStyle())
                .padding(.top, 6)

                Spacer()
            }
            .padding(20)
        }
        .preferredColorScheme(.dark)
    }
}

private struct PosterCard: View {

    let title: String
    let year: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            RoundedRectangle(cornerRadius: 12)
                .fill(QPTheme.card)
                .frame(height: 130)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(2)

                Text(year)
                    .font(.system(size: 11))
                    .foregroundStyle(QPTheme.subtle)
            }
            .padding(8)
        }
    }
}

#Preview {
    MovieFeedView(
        onOpenSettings: { },
        onOpenDetails: { _ in }
    )
}
