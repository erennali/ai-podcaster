import Foundation

class EnvironmentManager {
    static let shared = EnvironmentManager()
    
    private var environmentVariables: [String: String] = [:]
    
    private init() {
        loadEnvironmentVariables()
    }
    
    private func loadEnvironmentVariables() {
        guard let envPath = Bundle.main.path(forResource: ".env", ofType: nil) else {
            print("Warning: .env file not found")
            return
        }
        
        do {
            let envContent = try String(contentsOfFile: envPath, encoding: .utf8)
            let lines = envContent.components(separatedBy: .newlines)
            
            for line in lines {
                let parts = line.components(separatedBy: "=")
                if parts.count == 2 {
                    let key = parts[0].trimmingCharacters(in: .whitespaces)
                    let value = parts[1].trimmingCharacters(in: .whitespaces)
                    environmentVariables[key] = value
                }
            }
        } catch {
            print("Error loading .env file: \(error)")
        }
    }
    
    func getAPIKey() -> String? {
        return environmentVariables["GENERATIVE_AI_API_KEY"]
    }
    func getElevenlabsAPIKey() -> String? {
        return environmentVariables["ELEVENLABS_API_KEY"]
    }
}
