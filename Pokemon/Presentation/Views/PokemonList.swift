import SwiftUI
import Combine

struct PokemonList: View {
    @ObservedObject var presenter: PokemonsPresenterImpl
    @State private var scrollToId: Int?
    @Namespace private var animation
    
    init(presenter: PokemonsPresenterImpl) {
        self.presenter = presenter
        Task {
            presenter.viewDidLoad()
        }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.red
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        let navigationAppearence =  UINavigationBar.appearance()
        navigationAppearence.standardAppearance = appearance
        navigationAppearence.scrollEdgeAppearance = appearance
    }
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                ScrollViewReader { proxy in
                    VStack {
                        loadingView.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                        errorView
                        successView(proxy: proxy)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).navigationBarTitle("", displayMode: .inline)
                    
                }.background(Color.gray.opacity(0.1)).toolbar {
                    ToolbarItem(placement: .principal) {
                        Image("logo")
                            .resizable().frame(width: 110, height: 40).padding(.bottom, 8)
                    }
                }}
            
        }
    }
    
    
    private var loadingView: some View {
        Group {
            VStack {
                if presenter.isLoading {
                    Spacer().padding(.top, 10)
                    ProgressView()
                    Text("Loading")
                }
            }
        }.frame(maxWidth: .infinity).background(Color.white)
    }
    
    private var errorView: some View {
        Group {
          if let error = presenter.error {
            Spacer().padding(.top, 10)
                Text(error)
            }
        }
    }
    
    private func successView(proxy: ScrollViewProxy) -> some View {
        Group {
          if
               let pokemons = presenter.pokemons {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]) {
                    ForEach(pokemons) { item in
                        PokemonItem(item: item)
                            .onAppear {
                                if item.id == pokemons.last?.id {
                                    if presenter.isLoadingBottom {
                                        return
                                    }
                                    Task {
                                        await presenter.fetchPokemons(loadMore: true)
                                    }
                                }
                            }
                    }
                }
                .padding()
            }
        }
    }
}

    
    struct PokemonItem: View {
        let item: PokemonEntity
        let screenSize = UIScreen.main.bounds.size
        
        var body: some View {
            
            VStack {
                VStack {
                    HStack{
                        Text("#\(item.id)").fontWeight(.bold).padding(.top, 8).padding(.leading, 8)
                        Spacer()
                    }
                    AsyncImage(url: URL(string: item.imageUrl)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 100, maxHeight: 100)
                    } placeholder: {
                        VStack {
                            ProgressView()
                        }.frame(maxWidth: 100, maxHeight: 100)
                    }
                    Text("\(item.name.capitalized)").padding(.bottom, 8)
                }.frame(width: screenSize.width/2 - 30)
            }   .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.top, 8)
                .padding(.leading, 8)
                .padding(.bottom, 8)
                .padding(.trailing, 8)
        }
    }
    
    #Preview {
        PokemonList(presenter: PokemonsPresenterImpl(fetchPokemonsUsecase: FetchPokemonsUsecaseImpl(repository: PokemonRepositoryImpl(datasource: PokemonDatasourceImpl(clientHttp: ClientHttpImpl(session: URLSession.shared))))))
    }
