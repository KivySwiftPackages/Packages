// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import PathKit

struct GitHubRepo: Decodable {
    let id: Int
    let node_id: String
    let name: String
    let full_name: String
    let `private`: Bool
}

struct SwiftPackage: Encodable {
    let url: String
}

class CollectionJSON: Encodable {
    
    
    
    var name: String
    var overview: String
    var keywords: [String]
    var arthor: String
    
    var repos: [GitHubRepo]
    
    var packages: [SwiftPackage] {
        repos.map { repo in
            .init(url: "https://github.com/\(repo.full_name).git")
        }
    }
    
    init(name: String, overview: String, keywords: [String], arthor: String, repos: [GitHubRepo]) {
        self.name = name
        self.overview = overview
        self.keywords = keywords
        self.arthor = arthor
        self.repos = repos
    }
    
    enum CodingKeys: CodingKey {
        case name
        case overview
        case keywords
        case arthor
        case packages
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(overview, forKey: .overview)
        try c.encode(keywords, forKey: .keywords)
        try c.encode(arthor, forKey: .arthor)
        try c.encode(packages, forKey: .packages)
    }
    
}

@main
struct ReposDumper: AsyncParsableCommand {
    func run() async throws {
        let url = URL(string: "https://api.github.com/users/kivyswiftpackages/repos")!

        let (data, _) = try await URLSession.shared.data(from: url)
        let repos = try JSONDecoder().decode([GitHubRepo].self, from: data)
        repos.filter({$0.name != "Packages"}).forEach { print($0) }
        
        let inputJson = try JSONEncoder().encode(CollectionJSON(
            name: "Kivy Packages",
            overview: "Kivy Swift packages",
            keywords: ["swift", "python", "kivy"],
            arthor: "PythonSwiftLink",
            repos: repos.filter({$0.name != "Packages"})
        ))
        let inputJsonPath = (Path.current + "input.json")
        try inputJsonPath.write(inputJson)
    }
}
