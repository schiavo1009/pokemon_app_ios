import Foundation
import Combine
import SwiftUI

protocol PokemonsPresenter: ObservableObject {
    func viewDidLoad()
    func fetchPokemons(loadMore: Bool) async
    var isLoadingBottom: Bool {get set}
    var isLoading: Bool {get set}
    var error: String? {get set}
    var pokemons: [PokemonEntity]? {get set}
}

class PokemonsPresenterImpl: PokemonsPresenter {
    
    private var fetchPokemonsUsecase: FetchPokemonsUsecase
    @Published var pokemons: [PokemonEntity]? = []
    @Published var isLoadingBottom: Bool = false
    @Published var isLoading: Bool = true
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
        await updateError(value: nil)
        
        if(loadMore){
            await self.updateIsLoadingBottom(value: true)
        } else{
            await self.updateIsLoading(value: true)
        }
        
        let result = await fetchPokemonsUsecase.getPokemons(offset: pokemons?.count ?? 0, limit: 20)
        await self.updateIsLoadingBottom(value: false)
        await self.updateIsLoading(value: false)
        switch result {
        case .success(let pokemons):
            await handlerSuccess(pokemons: pokemons, loadMore: loadMore)
        case .failure(let error):
            if !loadMore {
                await  handleError(error: error)
            }
        }
    }
    
    func handlerSuccess(pokemons: [PokemonEntity], loadMore: Bool = false) async {
        await self.updatePokemons(value: pokemons)
    }
    
    @MainActor
    private func updatePokemons(value: [PokemonEntity], loadMore: Bool = false) {
        self.pokemons?.append(contentsOf: value)
    }
    
    @MainActor
    private func updateIsLoading(value: Bool) {
        self.isLoading = value
    }
    
    @MainActor
    private func updateIsLoadingBottom(value: Bool) {
        self.isLoadingBottom = value
    }
    
    @MainActor
    private func updateError(value: String?) {
        self.error = value
    }
    
    func handleError(error: Error) async {
       await updateError(value: "Unexpected error, try again")
    }
}
