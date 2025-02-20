import SwiftUI
import Combine

struct PokemonList: View {
    @ObservedObject var presenter: PokemonsPresenterImpl
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
                VStack {
                    if presenter.state is StateLoading {
                        ProgressView()
                        Text("Loading")
                    }
                    if presenter.state is StateError {
                        
                        Text("Error")
                    }
                    
                    if let stateSuccess = presenter.state as? StateSuccess<[PokemonEntity]>,
                       let pokemons = stateSuccess.data {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ])
                        {
                            ForEach(pokemons) { item in
                                PokemonItem(item: item)
                            }
                        }  .padding()
                        
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).navigationBarTitle("", displayMode: .inline)
                
            }.background(Color.gray.opacity(0.1)).toolbar {
                ToolbarItem(placement: .principal) {
                    Image("logo")
                        .resizable().frame(width: 110, height: 40).padding(.bottom, 8)
                }
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
                    Text("#\(item.id)").padding(.top, 8).padding(.leading, 8)
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

struct ScreenSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    var screenSize: CGSize {
        get { self[ScreenSizeKey.self] }
        set { self[ScreenSizeKey.self] = newValue }
    }
}


struct ScreenSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .environment(\.screenSize, geometry.size)
        }
    }
}

extension View {
    func screenSize() -> some View {
        self.modifier(ScreenSizeModifier())
    }
}

#Preview {
    PokemonList(presenter: PokemonsPresenterImpl(fetchPokemonsUsecase: FetchPokemonsUsecaseImpl(repository: PokemonRepositoryImpl(datasource: PokemonDatasourceImpl(clientHttp: ClientHttpImpl(session: URLSession.shared))))))
}
