//
//  ClientHttp.swift
//  Pokemon
//
//  Created by Matheus Cereja on 13/02/25.
//

import Foundation

protocol ClientHttp {
    func get(url: String) async throws -> Data
}
