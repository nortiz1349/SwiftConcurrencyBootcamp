//
//  DownloadImageAsync.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Nortiz M1 on 2022/10/26.
//

import SwiftUI
import Combine

class DownloadImageAsyncImageLoader {
	
	let url = URL(string: "https://picsum.photos/200")!
	
	func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
		guard let data = data,
			  let image = UIImage(data: data),
			  let response = response as? HTTPURLResponse,
			  200..<300 ~= response.statusCode else {
			return nil
		}
		return image
	}
	
	func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
		URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			let image = self?.handleResponse(data: data, response: response)
			completionHandler(image, error)
		}
		.resume()
	}
	
	func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
		URLSession.shared.dataTaskPublisher(for: url)
			.map(handleResponse)
			.mapError({ $0 })
			.eraseToAnyPublisher()
	}
	
	func downladWithAsync() async throws -> UIImage? {
		do {
			let (data, response) = try await URLSession.shared.data(from: url)
			return handleResponse(data: data, response: response)
		} catch {
			throw error
		}
	}
	
}


class DownloadImageAsyncViewModel: ObservableObject {
	
	@Published var image: UIImage? = nil
	private let loader = DownloadImageAsyncImageLoader()
	private var cancellables = Set<AnyCancellable>()
	
	func fetchImage() async {
		/*
		loader.downloadWithEscaping { [weak self] image, error in
			DispatchQueue.main.async {
				self?.image = image
			}
		}
		*/ /// download With Escaping
		/*
		loader.downloadWithCombine()
			.receive(on: DispatchQueue.main)
			.sink { error in
				print(error)
			} receiveValue: { [weak self] image in
				self?.image = image
			}
			.store(in: &cancellables)
		*/ /// download with Combine
		
		let image = try? await loader.downladWithAsync()
		await MainActor.run {
			self.image = image
		}
		/// download with Async await
	}
	
}

struct DownloadImageAsync: View {
	
	@StateObject private var vm = DownloadImageAsyncViewModel()
	
	var body: some View {
		ZStack {
			if let image = vm.image {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
					.frame(width: 250, height: 250)
			}
		}
		.onAppear {
			Task {
				await vm.fetchImage()
			}
		}
	}
}

struct DownloadImageAsync_Previews: PreviewProvider {
	static var previews: some View {
		DownloadImageAsync()
	}
}
