import Foundation
import Security

/// A small, type-safe wrapper around the iOS Keychain.
///
/// Secrets — auth tokens, encryption keys, anything sensitive — belong here,
/// never in `UserDefaults` (which is plain, unencrypted plist on disk). Items are
/// stored with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`: readable only
/// while the device is unlocked and never synced or migrated to a new device.

struct KeychainService {

    enum KeychainError: Error, Equatable {
        case unexpectedStatus(OSStatus)
    }

    let service: String

    init(service: String = "com.vaultly.app") {
        self.service = service
    }

    func save(_ data: Data, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String:            kSecClassGenericPassword,
            kSecAttrService as String:      service,
            kSecAttrAccount as String:      key,
            kSecValueData as String:        data,
            kSecAttrAccessible as String:   kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)            // replace if it exists
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func read(_ key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String:        kSecClassGenericPassword,
            kSecAttrService as String:  service,
            kSecAttrAccount as String:  key,
            kSecReturnData as String:   true,
            kSecMatchLimit as String:   kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        return result as? Data
    }

    func delete(_ key: String) throws {
        let query: [String: Any] = [
            kSecClass as String:        kSecClassGenericPassword,
            kSecAttrService as String:  service,
            kSecAttrAccount as String:  key
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}

// MARK: - Codable convenience

extension KeychainService {
    func save<T: Encodable>(_ value: T, for key: String) throws {
        try save(try JSONEncoder().encode(value), for: key)
    }

    func read<T: Decodable>(_ type: T.Type, for key: String) throws -> T? {
        guard let data = try read(key) else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
