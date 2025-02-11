import Foundation
import AVFoundation
import FirebaseFirestore
import FirebaseAuth

class APIManager {
    private var apiKey: String? {
        get {
            return UserDefaults.standard.string(forKey: "apiKey")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "apiKey")
        }
    }

    init() {
        if apiKey == nil {
            fetchAPIKeyFromFirestore()
        } else {
            print("API Key fetched from cache: \(apiKey ?? "No API Key")")
        }
    }

    private func fetchAPIKeyFromFirestore() {
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }

        let db = Firestore.firestore()
        let docRef = db.collection("users").document(user.uid)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.apiKey = document.data()?["apiKey"] as? String
                print("API Key fetched from Firestore: \(self.apiKey ?? "No API Key")")
            } else {
                print("Document does not exist: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func ensureApiKey(completion: @escaping (Bool) -> Void) {
        if let _ = self.apiKey {
            completion(true)
        } else {
            fetchAPIKeyFromFirestore()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                completion(self.apiKey != nil)
            }
        }
    }

    func transcribeAudio(audioURL: URL, completion: @escaping (String?) -> Void) {
        ensureApiKey { success in
            guard success, let apiKey = self.apiKey else {
                print("API Key is not available.")
                completion(nil)
                return
            }

            var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
            request.httpMethod = "POST"
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            var body = Data()
            let boundaryPrefix = "--\(boundary)\r\n"

            body.append(boundaryPrefix)
            body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n")
            body.append("whisper-1\r\n")

            body.append(boundaryPrefix)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(audioURL.lastPathComponent)\"\r\n")
            body.append("Content-Type: audio/m4a\r\n\r\n")
            body.append(try! Data(contentsOf: audioURL))
            body.append("\r\n")

            body.append("--\(boundary)--\r\n")

            request.httpBody = body

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let text = json["text"] as? String {
                    completion(text)
                } else {
                    completion(nil)
                }
            }.resume()
        }
    }

    func chatCompletion(with text: String, language: String, completion: @escaping (String?) -> Void) {
        ensureApiKey { success in
            guard success, let apiKey = self.apiKey else {
                print("API Key is not available.")
                completion(nil)
                return
            }

            var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
            request.httpMethod = "POST"
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

            let json: [String: Any] = [
                "model": "gpt-4",
                "messages": [
                    ["role": "system", "content": "You are a translator and your job is to translate whatever text given to you, do not add anything else on your own, don't say anything other than the text provided to you. You are translating the given text to this language: \(language)"],
                    ["role": "user", "content": text]
                ]
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: json)
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let choices = json["choices"] as? [[String: Any]], let message = choices.first?["message"] as? [String: Any], let content = message["content"] as? String {
                    completion(content)
                } else {
                    completion(nil)
                }
            }.resume()
        }
    }

    func textToSpeech(text: String, completion: @escaping (URL?) -> Void) {
        ensureApiKey { success in
            guard success, let apiKey = self.apiKey else {
                print("API Key is not available.")
                completion(nil)
                return
            }

            let selectedVoice = UserDefaults.standard.string(forKey: "selectedVoice") == "Male" ? "echo" : "alloy"

            var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/speech")!)
            request.httpMethod = "POST"
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

            let json: [String: Any] = ["model": "tts-1", "voice": selectedVoice, "input": text]
            let jsonData = try! JSONSerialization.data(withJSONObject: json)
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("response.mp3")
                    do {
                        try data.write(to: fileURL)
                        completion(fileURL)
                    } catch {
                        print("Failed to save audio file: \(error.localizedDescription)")
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }.resume()
        }
    }

    func translateText(from: String, to: String, text: String, completion: @escaping (String?) -> Void) {
        ensureApiKey { success in
            guard success, let apiKey = self.apiKey else {
                print("API Key is not available.")
                completion(nil)
                return
            }

            var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
            request.httpMethod = "POST"
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

            let json: [String: Any] = [
                "model": "gpt-4",
                "messages": [
                    ["role": "system", "content": "You are a translator.Even though the user inputs the wrong text, translate it to given language and don't add any comments to the answer. Translate the given text from \(from) to \(to)."],
                    ["role": "user", "content": text]
                ]
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: json)
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let choices = json["choices"] as? [[String: Any]], let message = choices.first?["message"] as? [String: Any], let content = message["content"] as? String {
                    completion(content)
                } else {
                    completion(nil)
                }
            }.resume()
        }
    }

    func clearApiKey() {
        UserDefaults.standard.removeObject(forKey: "apiKey")
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
