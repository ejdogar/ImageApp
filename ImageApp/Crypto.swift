//
//  Crypto.swift
//  ImageApp
//
//  Created by Ej Dogar on 26/01/2024.
//

import Foundation
import CryptoKit

public extension Optional {
    func tryUnwrap() throws -> Wrapped {
        if let value = self {
            return value
        } else {
            throw NSError(domain: "", code: 0)
        }
    }
}

public struct Crypto {
    static func encrypt(input: Data, key: String) -> Data {
        do {
            let keyData = Data(key.data(using: .utf8)!.prefix(32))
            let key = SymmetricKey(data: keyData)
            let sealed = try AES.GCM.seal(input, using: key)
            return try sealed.combined.tryUnwrap()
        } catch {
            return input
        }
    }
    
    static func decrypt(input: Data, key: String) -> Data {
        do {
            let keyData = Data(key.data(using: .utf8)!.prefix(32))
            let key = SymmetricKey(data: keyData)
            let box = try AES.GCM.SealedBox(combined: input)
            let opened = try AES.GCM.open(box, using: key)
            return opened
        } catch {
            return input
        }
    }
}
