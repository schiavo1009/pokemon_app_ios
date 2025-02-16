import Foundation
protocol PokemonsPresenter {
    func viewDidLoad()
    func fetchPokemons(loadMore: Bool) async
    var pokemons: [PokemonEntity]? {get set}
    var isLoading: Bool {get set}
    var isLoadingBottom: Bool {get set}
    var error: String? {get set}
}

class PokemonsPresenterImpl: PokemonsPresenter, ObservableObject {
    
    private var fetchPokemonsUsecase: FetchPokemonsUsecase
    @Published var pokemons: [PokemonEntity]?
    @Published var isLoading: Bool = false
    @Published var isLoadingBottom: Bool = false
    @Published var error: String?
    
    init(fetchPokemonsUsecase: FetchPokemonsUsecase) {
        self.fetchPokemonsUsecase = fetchPokemonsUsecase
    }
    
    func viewDidLoad() {
        Task {
            await fetchPokemons()
        }
    }
    
    func fetchPokemons(loadMore: Bool = false) async {
        error = nil
        
        if(loadMore){
            isLoadingBottom = true
        } else{
            isLoading = true
        }
        
        let result = await fetchPokemonsUsecase.getPokemons(offset: pokemons?.count ?? 0, limit: 20)
        
        isLoadingBottom = false
        isLoading = false
        
        switch result {
        case .success(let pokemons):
            handlerSuccess(pokemons: pokemons, loadMore: loadMore)
        case .failure(let error):
            if !loadMore {
                handleError(error: error)
            }
        }
    }
    
    func handlerSuccess(pokemons: [PokemonEntity], loadMore: Bool = false) {
        if loadMore {
            self.pokemons?.append(contentsOf: pokemons)
            return
        }
        self.pokemons = pokemons
    }
    
    func handleError(error: Error) {
        self.error = "Unexpected error, try again"
    }
}
