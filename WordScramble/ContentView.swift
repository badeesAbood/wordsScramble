//
//  ContentView.swift
//  WordScramble
//
//  Created by MASARAT on 3/10/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var title = ""
    @State private var message = ""
    @State private var showingAlert = false
    
    @State private var score = 0
    
     
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word" , text: $newWord )
                        .textInputAutocapitalization(.never  )
                }
                
                Section {
                    ForEach(usedWords , id: \.self) { word in
                        HStack {
                            Image(systemName:"\(word.count).circle")
                            Text(word)

                        }
                    }
                }
               
            }.navigationTitle(rootWord)
                .toolbar {
                    Button("restart Game" , action: restartGame)
                }
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(title , isPresented: $showingAlert){} message: {
                    Text(message)
                }
            
            Section("Your Score is ") {
                Text(String(score)).font(.title)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        guard isReal(word: answer) else {
            wordError(title: "this is not real", message: "we cant use any word , can wer ")
            
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Used Already", message: "you cant use words that has been used")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible ", message: "this word cant be  soelled  from \(rootWord) !")
            return
        }
        
        guard isShort(word: answer) else {
            wordError(title: "Word is Short ", message: "you cant use a word that less than three charechters !")
            return
        }
        
        
        
        withAnimation {
            usedWords.insert(newWord, at: 0)
            calculateScore(word: answer)
        }
        
        newWord = ""
    }
    
    
    func startGame() {
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWord = try? String(contentsOf: startWordsUrl) {
                let allWords = startWord.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Couldn't load start.txt file from bundle")
    }
    
    func restartGame() {
        withAnimation {
            usedWords.removeAll()
        }
        score = 0 
        startGame()
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible (word: String) -> Bool {
        var tempWord = rootWord
        
        for letters in word {
            if let pos = tempWord.firstIndex(of: letters) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let chekcer = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let missSpilledRange = chekcer.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return missSpilledRange.location == NSNotFound
    }
    
    func isShort(word: String) -> Bool {
        word.count > 3
    }
    
    func wordError(title: String , message:String){
        self.title = title
        self.message = message
        
        showingAlert = true
    }
    
    func calculateScore(word: String ){
        score += word.count
    }
    
    
}

#Preview {
    ContentView()
}
