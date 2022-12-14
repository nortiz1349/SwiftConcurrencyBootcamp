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
				NavigationLink("CLICK ME! π₯³") {
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
		/// νλ©΄ μ νμ μλμΌλ‘ taskκ° μ·¨μλλ€.
		///
		.task {
			await vm.fetchImage()
		}
		/// μ΄λ―Έμ§ λ‘λ©μ 5μ΄κ° κ±Έλ¦¬λ μν©μ κ°μ νλ€.
		/// μ΄λ―Έμ§ λ‘λ©μ€μ νλ©΄μ μ ννλ κ²½μ° λ‘λ©μ μ·¨μν  νμκ° μλ€. (μ·¨μ νμ§ μμΌλ©΄ λ°±κ·ΈλΌμ΄λμμ κ³μν΄μ λ‘λ© μμμ μννλ€.)
		/// μ΄ κ²½μ° μ λ€λ¦­ νμμ Task λ³μλ₯Ό μ μΈνκ³   onDisappear μμμ cancel νλ©΄ Task λ₯Ό μ·¨μν  μ μλ€.
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
			/// order of priorities - μ€ν μμλ₯Ό μ§μ νλ κ²μ μλλ€.
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
 
