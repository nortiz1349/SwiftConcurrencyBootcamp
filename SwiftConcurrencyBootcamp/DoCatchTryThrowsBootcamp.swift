//
//  DoCatchTryThrowsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Nortiz M1 on 2022/10/26.
//

import SwiftUI

// do-catch
// try
// throws

class DoCatchTryThrowsBootcampDataManager {
	
	let isActive: Bool = true
	
	func getTitle() -> (title: String?, error: Error?) {
		if isActive {
			return ("NEW TEXT!", nil)
		} else {
			return (nil, URLError(.badURL))
		}
	}
	
	func getTitle2() -> Result<String, Error> {
		if isActive {
			return .success("NEW TEXT!")
		} else {
			return .failure(URLError(.badURL))
		}
	}
	
	func getTitle3() throws -> String {
//		if isActive {
//			return "NEW TITLE!!"
//		} else {
			throw URLError(.badServerResponse)
//		}
	}
	
	func getTitle4() throws -> String {
		if isActive {
			return "Final Text!!"
		} else {
			throw URLError(.badServerResponse)
		}
	}
	
}


class DoCatchTryThrowsBootcampViewModel: ObservableObject {
	
	@Published var text: String = "Starting text."
	private let manager = DoCatchTryThrowsBootcampDataManager()
	
	func fetchTitle() {
		/*
		let returnedValue = manager.getTitle()
		if let newTitle = returnedValue.title {
			self.text = newTitle
		} else if let error = returnedValue.error {
			self.text = error.localizedDescription
		}
		*/
		/*
		let result = manager.getTitle2()
		
		switch result {
		case .success(let newTitle):
			self.text = newTitle
		case .failure(let error):
			self.text = error.localizedDescription
		}
		 */
		
//		let newTitle = try? manager.getTitle3()
//		if let newTitle = newTitle {
//			self.text = newTitle
//		}
		
		/// ⭐️ do구문 안의 try문이 fail이면 즉시 빠져나가 catch구문으로 이동한다.
		/// ⭐️ try? 옵셔널로 처리하면 throw 하는 error를 무시하고 nil 을 반환한다.

		do {
			let newTitle = try? manager.getTitle3() // throw error -> try? 사용으로 빠져나가지 않음
			if let newTitle = newTitle {
				self.text = newTitle
			}
			let finalTitle = try manager.getTitle4()
			self.text = finalTitle
		} catch let error {
			self.text = error.localizedDescription
		}
		
	}
}

struct DoCatchTryThrowsBootcamp: View {
	
	@StateObject private var vm = DoCatchTryThrowsBootcampViewModel()
	
    var body: some View {
		Text(vm.text)
			.frame(width: 200, height: 200)
			.background(.blue)
			.onTapGesture {
				vm.fetchTitle()
			}
    }
}

struct DoCatchTryThrowsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrowsBootcamp()
    }
}
