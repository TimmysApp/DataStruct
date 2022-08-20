//
//  File.swift
//  
//
//  Created by Joe Maghzal on 5/7/22.
//

import SwiftUI
import Combine
import CoreData

public final class ModelData<T: Datable>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    private var publishedData = CurrentValueSubject<[T], Error>([])
    private let fetchController: NSFetchedResultsController<T.Object>
    public init(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = []) {
        let fetchRequest = T.Object.fetchRequest() as! NSFetchRequest<T.Object>
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors ?? []
        guard let viewContext = DataConfigurations.shared.managedObjectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        super.init()
        fetchController.delegate = self
        do {
            try fetchController.performFetch()
            publishedData.value = fetchController.fetchedObjects?.model() ?? []
        }catch {
            publishedData.send(completion: Subscribers.Completion.failure(error))
        }
    }
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let data = controller.fetchedObjects as? [T.Object] else {return}
        self.publishedData.value = data.model()
    }
    public func with(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = []) -> ModelData<T> {
        return ModelData(predicate: predicate, sortDescriptors: sortDescriptors)
    }
    public func rawPublisher() -> AnyPublisher<[T], Error> {
        return publishedData.eraseToAnyPublisher()
    }
    public func publisher() -> AnyPublisher<[T], Never> {
        return publishedData
            .mapError { error -> Error in
                DataConfigurations.shared.errorsPublisher.send(error)
                return error
            }.replaceError(with: [])
            .eraseToAnyPublisher()
    }
}
