//
//  CheckedContinuationBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Nortiz M1 on 2022/10/28.
//

import SwiftUI


class CheckedContinuationBootcampNetworkManager {
	
	/// URLSession.shared.data 메서드는 이미 async 함수로 작성되어 있다.
	func getData(url: URL) async throws -> Data {
		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			return data
		} catch {
			throw error
		}
	}
	
	/// URLSession.shared.dataTask 메서드는 async 함수가 아니므로 별도로 비동기화 작업을 해야한다.
	func getData2(url: URL) async throws -> Data {
		return try await withCheckedThrowingContinuation { continuation in
			URLSession.shared.dataTask(with: url) { data, response, error in
				/// You must resume the continuation exactly once.
				/// 현재 클로저 내부에서 필수로 resume이 한번 실행되어져야 한다.
				if let data = data {
					continuation.resume(returning: data)
				} else if let error = error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume(throwing: URLError(.badURL))
				}
			}
			.resume()
		}
	}
	
	func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
			completionHandler(UIImage(systemName: "heart.fill")!)
		}
	}
	
	func getHeartImageFromDatabase() async -> UIImage {
		await withCheckedContinuation { continuation in
			getHeartImageFromDatabase { image in
				continuation.resume(returning: image)
			}
		}
	}
	
}

class CheckedContinuationBootcampViewModel: ObservableObject {
	
	@Published var image: UIImage? = nil
	let networkManager = CheckedContinuationBootcampNetworkManager()

	
	func getImage() async {
		guard let url = URL(string: "https://picsum.photos/1000") else { return }
		
		do {
			let data = try await networkManager.getData2(url: url)
			
			if let image = UIImage(data: data) {
				await MainActor.run {
					self.image = image
				}
			}
		} catch {
			print(error)
		}
	}
	
	func getHeartImage() async {
		self.image = await networkManager.getHeartImageFromDatabase()
		
	}
	
}


struct CheckedContinuationBootcamp: View {
	
	@StateObject private var vm = CheckedContinuationBootcampViewModel()
	
    var body: some View {
		
		ZStack {
			if let image = vm.image {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
					.frame(width: 200, height: 200)
			}
		}
		.task {
//			await vm.getImage()
			await vm.getHeartImage()
		}
    }
}

struct CheckedContinuationBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuationBootcamp()
    }
}
