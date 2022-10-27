//
//  TaskBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Nortiz M1 on 2022/10/27.
//

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
	
	@Published var image: UIImage? = nil
	@Published var image2: UIImage? = nil
	
	func fetchImage() async {
		try? await Task.sleep(nanoseconds: 5_000_000_000)
		do {
			guard let url = URL(string: "https://picsum.photos/1000") else { return }
			let (data, _) = try await URLSession.shared.data(from: url)
			await MainActor.run(body: {
				self.image = UIImage(data: data)
				print("IMAGE RETURNED SUCCESSFULLY")
			})
		} catch {
			print(error.localizedDescription)
		}
	}
	
	func fetchImage2() async {
		do {
			guard let url = URL(string: "https://picsum.photos/200") else { return }
			let (data, _) = try await URLSession.shared.data(from: url)
			self.image2 = UIImage(data: data)
		} catch {
			print(error.localizedDescription)
		}
	}
	
}

struct TaskBootcampHomeView: View {
	
	var body: some View {
		NavigationStack {
			ZStack {
				NavigationLink("CLICK ME! 🥳") {
					TaskBootcamp()
				}
			}
		}
	}
	
}

struct TaskBootcamp: View {
	
	@StateObject private var vm = TaskBootcampViewModel()
	@State private var fetchImageTask: Task<(), Never>? = nil
	
    var body: some View {
		VStack(spacing: 40) {
			if let image = vm.image {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
					.frame(width: 200, height: 200)
			}
			if let image = vm.image2 {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
					.frame(width: 200, height: 200)
			}
		}
		/// 화면 전환시 자동으로 task가 취소된다.
		///
		.task {
			await vm.fetchImage()
		}
		/// 이미지 로딩에 5초가 걸리는 상황을 가정한다.
		/// 이미지 로딩중에 화면을 전환하는 경우 로딩을 취소할 필요가 있다. (취소 하지 않으면 백그라운드에서 계속해서 로딩 작업을 수행한다.)
		/// 이 경우 제네릭 타입의 Task 변수를 선언하고  onDisappear 안에서 cancel 하면 Task 를 취소할 수 있다.
		/*
		.onDisappear {
			fetchImageTask?.cancel()
		}
		.onAppear {
			fetchImageTask = Task {
				await vm.fetchImage()
			}
			Task {
				await vm.fetchImage2()
			}
		*/
			/// order of priorities - 실행 순서를 지정하는 것은 아니다.
			/*
			Task(priority: .high) {
				try? await Task.sleep(nanoseconds: 2_000_000_000)
				await Task.yield()
				print("HIGH : \(Thread.current) \(Task.currentPriority)")
			}
			Task(priority: .userInitiated) {
				print("USER INITIATED : \(Thread.current) \(Task.currentPriority)")
			}
			Task(priority: .medium) {
				print("MEDIUM : \(Thread.current) \(Task.currentPriority)")
			}
			Task(priority: .low) {
				print("LOW : \(Thread.current) \(Task.currentPriority)")
			}
			Task(priority: .utility) {
				print("UTILITY : \(Thread.current) \(Task.currentPriority)")
			}
			Task(priority: .background) {
				print("BACKGROUND : \(Thread.current) \(Task.currentPriority)")
			}
			*/
//		}
    }
}

struct TaskBootcamp_Previews: PreviewProvider {
    static var previews: some View {
		TaskBootcampHomeView()
    }
}
 
