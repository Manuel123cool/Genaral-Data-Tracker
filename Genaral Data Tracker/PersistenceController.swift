//
//  PersistenceController.swift
//  SwiftUICoreData
//
//  Created by Alex Nagy on 26.03.2021.
//
import CoreData

struct PersistenceController {
    
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    init() {
        container = NSPersistentContainer(name: "Stash")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save(completion: @escaping (Error?) -> () = {_ in}) {
        if context.hasChanges {
            do {
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func delete(_ object: NSManagedObject, completion: @escaping (Error?) -> () = {_ in}) {
        context.delete(object)
        save(completion: completion)
    }
    
    func reFetchResulults(_ entityString: String) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityString)
        var fetchResults: [NSManagedObject]
        do {
            fetchResults = try context.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            fatalError("Error in save Templates")
        }
        return fetchResults
    }
    
    func saveTemplate(_ template: OneEntrieData, indexes: [Int]) {
        let templateStore = TemplateStore(context: context)
        templateStore.biggerIsBetter = template.biggerIsBetter
        templateStore.data = template.data
        templateStore.dataEntrieTyp = "\(template.dataEntrieTyp)"
        templateStore.goal = template.goal
        templateStore.header = template.header
        templateStore.id = template.id
        templateStore.indexes = [indexes[0], indexes[1]]
        templateStore.options = template.options
        templateStore.userSet = template.userSet
        
        save()
    }
    
    func saveEntity(_ entity: OneDataEntitiy) {
        let entityStore = EntityStore(context: context)
        entityStore.boolState = entity.boolState
        entityStore.stringState = entity.stringState
        entityStore.date = entity.date
        entityStore.indexRelatedTemplate = entity.indexRelatedTemplate
        entityStore.id = entity.id
        
        save()
    }
    
    func updateTemplateData(_ data: String, _ id: UUID) {
        reTempFetchForId(id: id).setValue(data, forKey: "data")
        save()
    }
    
    func deleteTemplate(_ id: UUID, _ getsZero: Bool) {
        var indexesDeleted = [Int]()
        
        for templateFetch in reFetchResulults("TemplateStore") {
            if templateFetch.value(forKey: "id") as! UUID == id {
                indexesDeleted = templateFetch.value(forKey: "indexes") as! [Int]
                delete(templateFetch)
                break
            }
        }
        
        for templateFetch in reFetchResulults("TemplateStore") {
            let currentIndexes = templateFetch.value(forKey: "indexes") as! [Int]
            if currentIndexes[0] > indexesDeleted[0] && getsZero {
                var newIndexes = [currentIndexes[0] - 1, currentIndexes[1]]
                if currentIndexes[1] > indexesDeleted[1] {
                    newIndexes[1] -= 1
                }
                templateFetch.setValue(newIndexes, forKey: "indexes")
                save()
            }
            if currentIndexes[0] == indexesDeleted[0] && currentIndexes[1] > indexesDeleted[1] {
                let newIndexes = [currentIndexes[0], currentIndexes[1] - 1]
                templateFetch.setValue(newIndexes, forKey: "indexes")
                save()
            }
        }
        
        for entityFetch in reFetchResulults("EntityStore") {
            let currentIndexes = entityFetch.value(forKey: "indexRelatedTemplate") as! [Int]
            if currentIndexes == indexesDeleted {
                delete(entityFetch)
            }
        }
        
        for entityFetch in reFetchResulults("EntityStore") {
            let currentIndexes = entityFetch.value(forKey: "indexRelatedTemplate") as! [Int]
            if currentIndexes[0] > indexesDeleted[0] && getsZero {
                let newIndexes = [currentIndexes[0] - 1, currentIndexes[1]]
                entityFetch.setValue(newIndexes, forKey: "indexRelatedTemplate")
                save()
            }
            if currentIndexes[0] == indexesDeleted[0] && currentIndexes[1] > indexesDeleted[1] {
                let newIndexes = [currentIndexes[0], currentIndexes[1] - 1]
                entityFetch.setValue(newIndexes, forKey: "indexRelatedTemplate")
                save()
            }
        }
    }
    
    func deleteEntity(_ id: UUID) {
        for entityFetch in reFetchResulults("EntityStore") {
            if entityFetch.value(forKey: "id") as! UUID == id {
                delete(entityFetch)
                break
            }
        }
    }
    
    
    func initEntities(_ entites: inout [OneDataEntitiy],
                    _ templates: [[OneEntrieData]]) {
        
        var reEnties = [OneDataEntitiy]()
        
        let fetchRequest: NSFetchRequest<EntityStore>
        fetchRequest = EntityStore.fetchRequest()
        
        let entitiesObj: [EntityStore]
        do {
            entitiesObj = try context.fetch(fetchRequest)
        } catch {
            fatalError("Error in init Templates")
        }
        
        for entityObj in entitiesObj {
            let indexes = entityObj.indexRelatedTemplate!
            let templateData = templates[indexes[0]][indexes[1]]
            var oneEntity = OneDataEntitiy(templateData: templateData,
                                           indexRelatedTemplate: indexes,
                                           date: entityObj.date!)
            oneEntity.id = entityObj.id!
            oneEntity.stringState = entityObj.stringState!
            oneEntity.boolState = entityObj.boolState
            
            reEnties.append(oneEntity)
        }
        
        entites = reEnties
    }
    
    func initTemplates(_ templates: inout [[OneEntrieData]]) -> [[OneEntrieData]] {
        var templatesUnsorted: [(OneEntrieData, [Int])] = []
        
        let fetchRequest: NSFetchRequest<TemplateStore>
        fetchRequest = TemplateStore.fetchRequest()
        
        let templatesObj: [TemplateStore]
        do {
            templatesObj = try context.fetch(fetchRequest)
        } catch {
            fatalError("Error in init Templates")
        }
        
        for templateObj in templatesObj {
            var oneTemplate = OneEntrieData(dataEntrieTyp:
                                                reDataEntrieTyp(
                                                    templateObj.dataEntrieTyp!))
            oneTemplate.id = templateObj.id!
            oneTemplate.data = templateObj.data!
            oneTemplate.options = templateObj.options!
            oneTemplate.header = templateObj.header!
            oneTemplate.goal = templateObj.goal
            oneTemplate.biggerIsBetter = templateObj.biggerIsBetter
            oneTemplate.userSet = templateObj.userSet
            
            let indexes = templateObj.indexes!
            templatesUnsorted.append((oneTemplate, indexes))
        }
        
        var templatesSorted: [[(OneEntrieData, [Int])]] = []

        var groupIndexes = [Int]()
        for templateUnsorted in templatesUnsorted {
            var groupFound = false
            for groupIndex in groupIndexes {
                if templateUnsorted.1[0] == groupIndex {
                    groupFound = true
                }
            }
            if !groupFound {
                groupIndexes.append(templateUnsorted.1[0])
                templatesSorted.append([])
            }
        }
        
        for (index, _) in templatesSorted.enumerated() {
            for templateUnsorted in templatesUnsorted {
                if templateUnsorted.1[0] == index {
                    templatesSorted[index].append((templateUnsorted.0, templateUnsorted.1))
                }
            }
        }
        
        for (index, templateGroup) in templatesSorted.enumerated() {
            for index1 in 0..<templateGroup.count {
                let tmpTemplate = templatesSorted[index].remove(at: index1)
                templatesSorted[index].insert(tmpTemplate, at: tmpTemplate.1[1])
            }
        }
        
        templates = []
        for (index, templateGroup) in templatesSorted.enumerated() {
            templates.append([])
            for template in templateGroup {
                templates[index].append(template.0)
            }
        }
        return templates
    }
    
    func reDataEntrieTyp(_ typString: String) -> DataEntrieTyp {
        switch typString {
        case "quantity":
            return .quantity
        case "yesOrNo":
            return .yesOrNo
        case "options":
            return .options
        case "note":
            return .note
        default:
            print("String to entrie gone wrong")
            return .note
        }
    }
    
    func checkForEditGroup(_ templates: [OneEntrieData], _ groupIndex: Int) {
        for templateFetch in reFetchResulults("TemplateStore") {
            var notThere = true
            let fetchTemId = templateFetch.value(forKey: "id") as! UUID
            let deletedIndex = templateFetch.value(forKey: "indexes") as! [Int]

            for template in templates {
                if  fetchTemId == template.id {
                    notThere = false
                    
                    templateFetch.setValue(template.data, forKey: "data")
                    templateFetch.setValue(template.header, forKey: "header")
                    save()
                }
            }
            if deletedIndex[0] != groupIndex {
                notThere = false
            }
            
            if notThere {
                delete(templateFetch)
                
                for entityFetch in reFetchResulults("EntityStore") {
                    let currentIndexes = entityFetch.value(forKey: "indexRelatedTemplate") as! [Int]
                    if currentIndexes == deletedIndex {
                        delete(entityFetch)
                    }
                }
            }
        }
        
        for (index, template) in templates.enumerated() {
            var notThere = true
            let indexes = [groupIndex, index]
            for templateFetch in reFetchResulults("TemplateStore") {
                let fetchTemId = templateFetch.value(forKey: "id") as! UUID

                if fetchTemId == template.id {
                    notThere = false
                    let oldIndex = templateFetch.value(forKey: "indexes") as! [Int]

                    templateFetch.setValue(indexes, forKey: "indexes")
                    save()
                    
                    for entityFetch in reFetchResulults("EntityStore") {
                        let currentIndexes = entityFetch.value(forKey: "indexRelatedTemplate") as! [Int]
                        if currentIndexes == oldIndex {
                            entityFetch.setValue(indexes, forKey: "indexRelatedTemplate")
                            save()
                        }
                    }
                }
            }
            
            if notThere {
                saveTemplate(template, indexes: indexes)
            }
        }
        
        if templates.count == 0 {
            for entityFetch in reFetchResulults("EntityStore") {
                let currentIndexes = entityFetch.value(forKey: "indexRelatedTemplate") as! [Int]
                if currentIndexes[0] > groupIndex {
                    let newIndexes = [currentIndexes[0] - 1, currentIndexes[1]]
                    entityFetch.setValue(newIndexes, forKey: "indexRelatedTemplate")
                    save()
                }
            }
            
            for templateFetch in reFetchResulults("TemplateStore") {
                let currentIndexes = templateFetch.value(forKey: "indexes") as! [Int]
                if currentIndexes[0] > groupIndex {
                    let newIndexes = [currentIndexes[0] - 1, currentIndexes[1]]
                    templateFetch.setValue(newIndexes, forKey: "indexes")
                    save()
                }
            }
        }
    }
    
    func changeGoal(id: UUID, goal: Double) {
        reTempFetchForId(id: id).setValue(goal, forKey: "goal")
        save()
    }
    
    func changeBiggerIsBetter(id: UUID, biggerIsBetter: Bool) {
        reTempFetchForId(id: id).setValue(biggerIsBetter, forKey: "biggerIsBetter")
        save()
    }
    
    func changeUserSet(id: UUID, userSet: Bool) {
        reTempFetchForId(id: id).setValue(userSet, forKey: "userSet")
        save()
    }
    
    func reTempFetchForId(id: UUID) -> NSManagedObject {
        for templateFetch in reFetchResulults("TemplateStore") {
            if templateFetch.value(forKey: "id") as! UUID == id {
                return templateFetch
            }
        }
        return NSManagedObject()
    }
}
