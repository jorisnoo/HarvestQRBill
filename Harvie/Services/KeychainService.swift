//
//  KeychainService.swift
//  Harvie
//

import Foundation
import Security

actor KeychainService {
    static let shared = KeychainService()

    private let service = "app.harvie"
    private var cache: [KeychainKey: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    enum KeychainKey: String {
        case harvestCredentials = "harvest_credentials"
        case creditorInfo = "creditor_info"
        case appSettings = "app_settings"
    }

    enum KeychainError: Error, LocalizedError {
        case encodingFailed
        case decodingFailed
        case saveFailed(OSStatus)
        case loadFailed(OSStatus)
        case deleteFailed(OSStatus)
        case notFound

        var errorDescription: String? {
            switch self {
            case .encodingFailed:
                return Strings.Errors.keychainEncodingFailed
            case .decodingFailed:
                return Strings.Errors.keychainDecodingFailed
            case .saveFailed(let status):
                return Strings.Errors.keychainSaveFailed(Self.message(for: status))
            case .loadFailed(let status):
                return Strings.Errors.keychainLoadFailed(Self.message(for: status))
            case .deleteFailed(let status):
                return Strings.Errors.keychainDeleteFailed(Self.message(for: status))
            case .notFound:
                return Strings.Errors.keychainNotFound
            }
        }

        private static func message(for status: OSStatus) -> String {
            SecCopyErrorMessageString(status, nil) as String? ?? "code \(status)"
        }
    }

    func save<T: Encodable>(_ value: T, for key: KeychainKey) throws {
        let data = try encoder.encode(value)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        let updateAttributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)

        if status == errSecItemNotFound {
            let addQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key.rawValue,
                kSecValueData as String: data
            ]

            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)

            guard addStatus == errSecSuccess else {
                throw KeychainError.saveFailed(addStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.saveFailed(status)
        }

        cache[key] = data
    }

    func load<T: Decodable>(for key: KeychainKey) throws -> T {
        if let cached = cache[key] {
            return try decoder.decode(T.self, from: cached)
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.notFound
            }
            throw KeychainError.loadFailed(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.decodingFailed
        }

        cache[key] = data

        return try decoder.decode(T.self, from: data)
    }

    func delete(for key: KeychainKey) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }

        cache[key] = nil
    }

    func saveHarvestCredentials(_ credentials: HarvestCredentials) throws {
        try save(credentials, for: .harvestCredentials)
    }

    func loadHarvestCredentials() throws -> HarvestCredentials {
        try load(for: .harvestCredentials)
    }

    func saveCreditorInfo(_ info: CreditorInfo) throws {
        try save(info, for: .creditorInfo)
    }

    func loadCreditorInfo() throws -> CreditorInfo {
        try load(for: .creditorInfo)
    }

}
