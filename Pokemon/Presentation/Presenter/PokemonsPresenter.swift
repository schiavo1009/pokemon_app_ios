import Foundation
import Combine
import SwiftUI

class StatePage<T>: ObservableObject {
    
}

class StateSuccess<T>: StatePage<T> {
    var data: T?
    var loadBottomScroll: Bool
    init(data: T?, loadBottomScroll: Bool = false) {
        self.data = data
        self.loadBottomScroll = loadBottomScroll
    }
}

class StateError<T>: StatePage<T> {
    var message: String?
    init(message: String?) {
        self.message = message
    }
}

class StateLoading<T>: StatePage<T> {
}

protocol PokemonsPresenter: ObservableObject {
    func viewDidLoad()
    func fetchPokemons(loadMore: Bool) async
    var pokemons: [PokemonEntity]? {get set}
    var state: StatePage<[PokemonEntity]> {get set}
}

class PokemonsPresenterImpl: PokemonsPresenter {
    
    private var fetchPokemonsUsecase: FetchPokemonsUsecase
    var pokemons: [PokemonEntity]? = []
    @Published var state: StatePage<[PokemonEntity]> = StatePage<[PokemonEntity]>()
    
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
            await self.updateIsLoadingBottom()
        } else{
           await self.updateToLoadingState()
        }
        
        let result = await fetchPokemonsUsecase.getPokemons(offset: pokemons?.count ?? 0, limit: 20)
    
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
        if loadMore {
            var pokemonsLocal = self.pokemons ?? []
            pokemonsLocal.append(contentsOf: pokemons)
            await self.updatePokemons(value: pokemonsLocal)
            return
        }
        await self.updatePokemons(value: pokemons)
    }
    
    @MainActor
    private func updatePokemons(value: [PokemonEntity], loadMore: Bool = false) {
        self.pokemons = value
        self.state = StateSuccess(data: value)

    }
    
    @MainActor
    private func updateToLoadingState() {
        self.state = StateLoading()
    }
    
    @MainActor
    private func updateIsLoadingBottom() {
        self.state = StateSuccess(data: pokemons, loadBottomScroll: true)
    }
    
    @MainActor
    private func updateError(value: String?) {
        self.state = StateError(message: value)
    }
    
    func handleError(error: Error) async {
       await updateError(value: "Unexpected error, try again")
    }
}
