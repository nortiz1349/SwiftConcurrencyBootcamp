//
//  ActorsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Nortiz M1 on 2022/10/28.
//

// 1. What is the problem that actor are solving? - data race problem
// 2. How was this problem solved prior to actors?
// 3. Actors can solve the problem!

import SwiftUI

class MyDataManager {
	
	static let instance = MyDataManager()
	private init() { }
	
	var data: [String] = []
	private let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
	
	func getRandomData(completionHandler: @escaping (_ title: String?) -> ()) {
		lock.async {
			self.data.append(UUID().uuidString)
			print(Thread.current)
			completionHandler(self.data.randomElement())
		}
	}
}

actor MyActorManager { // Thread SAFE!
	
	static let instance = MyActorManager()
	private init() { }
	
	var data: [String] = []
	
	func getRandomData() -> String? {
		self.data.append(UUID().uuidString)
		print(Thread.current)
		return self.data.randomElement()
	}
	
	/// isolated actor 내부에서 isolate 되어질 필요가 없을 때
	/// actor 내부에 있지만 await 할 필요가 없을 때
	nonisolated func getSavedData() -> String {
		return "NEW DATA"
	}
	
}

struct HomeView: View {
	
	let manager = MyActorManager.instance
	@State private var text: String = ""
	let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
	
	var body: some View {
		ZStack {
			Color.gray.opacity(0.8).ignoresSafeArea()
			
			Text(text)
				.font(.headline)
		}
		.onAppear(perform: {
			Task {
//				let newString = manager.getSavedData() // nonisolated function
			}
		})
		.onReceive(timer) { _ in
			Task {
				if let data = await manager.getRandomData() {
					await MainActor.run(body: {
						self.text = data
					})
				}
			}
//			DispatchQueue.global(qos: .background).async {
//				manager.getRandomData { title in
//					if let data = title {
//						DispatchQueue.main.async {
//							self.text = data
//						}
//					}
//				}
//			}
		}
	}
}

struct BrowseView: View {
	
	let manager = MyActorManager.instance
	@State private var text: String = ""
	let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
	
	var body: some View {
		ZStack {
			Color.yellow.opacity(0.8).ignoresSafeArea()
			
			Text(text)
				.font(.headline)
		}
		.onReceive(timer) { _ in
			Task {
				if let data = await manager.getRandomData() {
					await MainActor.run(body: {
						self.text = data
					})
				}
			}
//			DispatchQueue.global(qos: .default).async {
//				manager.getRandomData { title in
//					if let data = title {
//						DispatchQueue.main.async {
//							self.text = data
//						}
//					}
//				}
//			}
		}
	}
}

struct ActorsBootcamp: View {
    var body: some View {
		TabView {
			HomeView()
				.tabItem {
					Label("Home", systemImage: "house.fill")
				}
			BrowseView()
				.tabItem {
					Label("Browse", systemImage: "magnifyingglass")
				}
		}
    }
}

struct ActorsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        ActorsBootcamp()
    }
}
