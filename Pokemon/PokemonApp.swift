import SwiftUI

@main
struct PokemonApp: App {
    var body: some Scene {
        WindowGroup {
            PokemonList(presenter: PokemonsPresenterImpl(fetchPokemonsUsecase: FetchPokemonsUsecaseImpl(repository: PokemonRepositoryImpl(datasource: PokemonDatasourceImpl(clientHttp: ClientHttpImpl(session: URLSession.shared))))))
        }
    }
}
