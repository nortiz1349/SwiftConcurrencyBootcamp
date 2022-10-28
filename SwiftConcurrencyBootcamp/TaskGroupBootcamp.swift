//
//  TaskGroupBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Nortiz M1 on 2022/10/27.
//

import SwiftUI

class TaskGroupBootcampDataManager {
	
	func fetchImagesAsyncLet() async throws -> [UIImage] {
		async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/1000")
		async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/1000")
		async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/1000")
		async let fetchImage4 = fetchImage(urlString: "https://picsum.photos/1000")
		
		let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
		
		return [image1, image2, image3, image4]
	}
	
	func fetchImagesWithTaskGroup() async throws -> [UIImage] {
		
		let urlStrings = [
			"https://picsum.photos/1000",
			"https://picsum.photos/1000",
			"https://picsum.photos/1000",
			"https://picsum.photos/1000",
			"https://picsum.photos/1000"
		]
		
		return try await withThrowingTaskGroup(of: UIImage?.self) { group in
			var images: [UIImage] = []
			images.reserveCapacity(urlStrings.count)
			
			for urlString in urlStrings {
				group.addTask {
					try? await self.fetchImage(urlString: urlString)
				}
			}
			
			for try await image in group {
				if let image = image {
					images.append(image)
				}
			}
			
			return images
		}
	}
	
	private func fetchImage(urlString: String) async throws -> UIImage {
		guard let url = URL(string: urlString) else {
			throw URLError(.badURL)
		}
		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			if let image = UIImage(data: data) {
				return image
			} else {
				throw URLError(.badServerResponse)
			}
		} catch {
			throw error
		}
	}
	
}


class TaskGroupBootcampViewModel: ObservableObject {
	
	@Published var images: [UIImage] = []
	let manager = TaskGroupBootcampDataManager()
	@Published var isLoading: Bool = false
	
	func getImages() async {
		isLoading = true
		if let images = try? await manager.fetchImagesWithTaskGroup() {
			self.images.append(contentsOf: images)
		}
		isLoading = false
	}
	
}

struct TaskGroupBootcamp: View {
	
	@StateObject private var vm = TaskGroupBootcampViewModel()
	let columns = [GridItem(.flexible()), GridItem(.flexible())]
	
	
    var body: some View {
		NavigationStack {
			ScrollView {
				if vm.isLoading {
					ProgressView()
				}
				LazyVGrid(columns: columns) {
					ForEach(vm.images, id: \.self) { image in
						Image(uiImage: image)
							.resizable()
							.scaledToFit()
							.frame(height: 150)
					}
				}
			}
			.navigationTitle("Task Group 🥳")
			.task {
				await vm.getImages()
			}
		}
    }
}

struct TaskGroupBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupBootcamp()
    }
}
