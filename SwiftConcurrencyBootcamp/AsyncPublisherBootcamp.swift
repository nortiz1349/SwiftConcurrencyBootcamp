//
//  AsyncPublisherBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Nortiz M1 on 2022/10/30.
//

import SwiftUI
import Combine

class AsyncPublisherBootcampDataManager {
	
	@Published var myData: [String] = []
	
	func addData() async {
		myData.append("Apple")
		try? await Task.sleep(nanoseconds: 2_000_000_000)
		myData.append("Banana")
		try? await Task.sleep(nanoseconds: 2_000_000_000)
		myData.append("Orange")
		try? await Task.sleep(nanoseconds: 2_000_000_000)
		myData.append("Watermelon")
	}
	
}

class AsyncPublisherBootcampViewModel: ObservableObject {
	
	@MainActor @Published var dataArray: [String] = []
	let manager = AsyncPublisherBootcampDataManager()
	var cancellables = Set<AnyCancellable>()
	
	init() {
		addSubscribers()
	}
	
	private func addSubscribers() {
		
		Task {
			await MainActor.run(body: {
				self.dataArray = ["One"]
			})
			
			
			for await value in manager.$myData.values {
				await MainActor.run(body: {
//					self.dataArray = value
				})
			}
		}
		
//		manager.$myData
//			.receive(on: DispatchQueue.main)
//			.sink { dataArray in
//				self.dataArray = dataArray
//			}
//			.store(in: &cancellables)
	}
	
	func start() async {
		await manager.addData()
	}
	
}

struct AsyncPublisherBootcamp: View {
	
	@StateObject private var vm = AsyncPublisherBootcampViewModel()
	
    var body: some View {
		ScrollView {
			VStack {
				ForEach(vm.dataArray, id: \.self) {
					Text($0)
						.font(.headline)
				}
			}
		}
		.task {
			await vm.start()
		}
    }
}

struct AsyncPublisherBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisherBootcamp()
    }
}
