//
//  AsyncAwaitBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Nortiz M1 on 2022/10/27.
//

import SwiftUI

class AsyncAwaitBootcampViewModel: ObservableObject {
	
	@Published var dataArray: [String] = []
	
	func addTitle1() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			self.dataArray.append("Title1 : \(Thread.current)")
		}
	}
	
	func addTitle2() {
		DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
			let title = "Title2 : \(Thread.current)"
			DispatchQueue.main.async {
				self.dataArray.append(title)
			}
		}
	}
	
	func addAuthor1() async {
		
		let author1 = "Author1"
		self.dataArray.append(author1)
		
		try? await Task.sleep(nanoseconds: 2_000_000_000)
		
		let author2 = "Author2"
		await MainActor.run {
			self.dataArray.append(author2)

			let author3 = "Author3 : \(Thread.current)"
			self.dataArray.append(author3)
		}
		
	}
}

struct AsyncAwaitBootcamp: View {
	
	@StateObject private var vm = AsyncAwaitBootcampViewModel()
	
    var body: some View {
		List {
			ForEach(vm.dataArray, id: \.self) { data in
				Text(data)
			}
		}
		.onAppear {
//			vm.addAuthor1()
			Task {
//				await vm.addAuthor1
			}
//			vm.addTitle1()
//			vm.addTitle2()
		}
    }
}

struct AsyncAwaitBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitBootcamp()
    }
}
