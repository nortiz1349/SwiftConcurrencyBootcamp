//
//  GlobalActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Nortiz M1 on 2022/10/29.
//

import SwiftUI

@globalActor
final class MyFirstGlobalActor {
	
	static var shared = MyNewDataManager()
	
}

actor MyNewDataManager {

	func getDataFromDatabase() -> [String] {
		return ["One", "Two", "Three", "Four", "Five"]
	}
	
}

class GlobalActorBootcampViewModel: ObservableObject {
	
	// published를 업데이트할때 @MainActor를 작성하면 메인스레드에서 업데이트 하지 않을 경우 컴파일러 에러를 내보낸다.
	@MainActor @Published var dataArray: [String] = []
	let manager = MyFirstGlobalActor.shared
	
	/// 뷰에서 이 메서드를 호출하면 main thread, main actor 에서 실행된다.
	/// 하지만 메인스레드에서 복잡하고 무거운 메서드를 실행시키고 싶지 않은 경우
	/// actor 외부에 있는 메서드를 actor 내부에 있는것과 같이 실행시키는 것
	/// When using
	/// such a declaration from another actor (or from nonisolated code),
	/// synchronization is performed through the "shared actor instance" to ensure
	/// mutually-exclusive access to the declaration.
	@MyFirstGlobalActor
//	@MainActor
	func getData() {
		
		// HEAVY COMPLEX METHODS
		Task {
			let data = await manager.getDataFromDatabase()
			await MainActor.run(body: {
				self.dataArray = data
			})
			
		}
	}
}

struct GlobalActorBootcamp: View {
	
	@StateObject private var vm = GlobalActorBootcampViewModel()
	
    var body: some View {
		ScrollView {
			VStack {
				ForEach(vm.dataArray, id: \.self) {
					Text($0)
						.font(.headline)
				}
			}
		}
		.task { // main actor
			await vm.getData()
		}
    }
	
}

struct GlobalActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActorBootcamp()
    }
}
