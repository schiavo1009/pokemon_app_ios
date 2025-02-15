import Foundation
protocol PokemonsPresenter {
    func viewDidLoad()
    func fetchPokemons() async
    var pokemons: [PokemonEntity]? {get set}
    var isLoading: Bool {get set}

}

class PokemonsPresenterImpl: PokemonsPresenter, ObservableObject {
    
    private var fetchPokemonsUsecase: FetchPokemonsUsecase
    @Published var pokemons: [PokemonEntity]?
    @Published var isLoading: Bool = false
    
    init(fetchPokemonsUsecase: FetchPokemonsUsecase) {
        self.fetchPokemonsUsecase = fetchPokemonsUsecase
    }
    
    func viewDidLoad() {
        Task {
            await fetchPokemons()
        }
    }
    
    func fetchPokemons() async {
        isLoading = true
        let result = await fetchPokemonsUsecase.getPokemons(offset: 0, limit: 20)
        isLoading = false
        switch result {
        case .success(let pokemons):
            self.pokemons = pokemons
        case .failure:
            pokemons = nil
            
        }
    }
    
}
