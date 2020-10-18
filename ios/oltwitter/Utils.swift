//
//  Utils.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import UIKit
import SwifteriOS

// From: https://stackoverflow.com/a/30593673/996404
extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

enum ServerData<T> {
    case notAsked
    case loading
    case success(T)
    case error(String)
}

class Utils {
    static func envVar(_ key: String) -> String? {
        if let processEnv = ProcessInfo.processInfo.environment[key] {
            return processEnv
        } else {
            let envFile = Bundle.main.path(forResource: ".env", ofType: nil)!
            do {
                let env = try String(contentsOfFile: envFile, encoding: .utf8)
                let envVars = env.split(separator: "\n")
                for env in envVars {
                    let keyValue = env.split(separator: "=")
                    if let key_ = keyValue[safe: 0],
                       let value = keyValue[safe: 1],
                       key_ == key
                       {
                        return String(value)
                    }
                }
            } catch {
                return nil
            }
        }
        return nil
    }

    static func timelineSample() -> JSON {
        let path = Bundle.main.path(forResource: "timeline", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))

        return JSON(data)
    }

    static func debug(_ str: String) {
        if ProcessInfo.processInfo.environment["DEBUG_SWIFT"] != nil {
            print(str)
        }
    }
}
