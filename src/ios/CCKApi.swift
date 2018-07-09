// swiftlint:disable trailing_whitespace line_length type_body_length file_length

import ClassKit

struct CCKContext: Decodable {
    let identifierPath: [String]
    let title: String
    let type: Int?
    let topic: String?
    let displayOrder: Int?
}

struct CCKBinaryItem: Decodable {
    let identifier: String
    let title: String
    let type: Int
    let isCorrect: Bool
    let isPrimaryActivityItem: Bool?
}

struct CCKScoreItem: Decodable {
    let identifier: String
    let title: String
    let score: Double
    let maxScore: Double
    let isPrimaryActivityItem: Bool?
}

struct CCKQuantityItem: Decodable {
    let identifier: String
    let title: String
    let quantity: Double
    let isPrimaryActivityItem: Bool?
}

@available(iOS 11.3, *)
@objc(CordovaClassKit) class CCKApi: CDVPlugin {
    var urlPrefix: String?
    var xmlElements: Set<ParsedXmlElement>?
    var activeContextIdentifier: [String]?

    // MARK: - init contexts defined in XML
    @objc(initContextsFromXml:) func initContextsFromXml(_ command: CDVInvokedUrlCommand) {
        CLSDataStore.shared.delegate = self
        
        if let urlPrefix = command.argument(at: 0) as? String {
            self.urlPrefix = urlPrefix.trimmingCharacters(in: .whitespaces)
        }
        
        let parser = CCKContextParser()
        do {
            try parser.parse(fileName: "CCK-contexts", { [weak self] (error, elements) in
                
                guard error == nil else {
                    self?.sendError(command: command, msg: nil, error: error!)
                    return
                }
                
                guard let elements = elements, elements.count > 0 else {
                    self?.sendError(command: command, msg: "No elements found", error: nil)
                    return
                }
                
                self?.xmlElements = []
                for element in elements {
                    self?.xmlElements!.insert(element)
                }
                
                guard let xmlElements = self?.xmlElements else {
                    self?.sendError(command: command, msg: "No elements found", error: nil)
                    return
                }
                
                for element in xmlElements {
                    CLSDataStore.shared.contexts(matchingIdentifierPath: element.identifierPath, completion: { [weak self] (contexts, error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                self?.sendError(command: command, msg: "Could not create contexts", error: error)
                            } else {
                                self?.sendOK(command: command, msg: "Contexts have been initialized")
                            }
                        }
                    })
                }
            })
        } catch {
            sendError(command: command, msg: nil, error: error)
        }
    }
    
    // MARK: - add context with identifier path
    @objc(addContext:) func addContext(_ command: CDVInvokedUrlCommand) {
        CLSDataStore.shared.delegate = self
        
        if let urlPrefix = command.argument(at: 0) as? String {
            self.urlPrefix = urlPrefix.trimmingCharacters(in: .whitespaces)
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: command.argument(at: 1), options: .prettyPrinted) else {
            sendError(command: command, msg: "Please provide a context object as the second parameter", error: nil)
            return
        }
        
        do {
            let context = try JSONDecoder().decode(CCKContext.self, from: data)
            
            // optionals
            var type: CLSContextType = .none
            if let typeValue = context.type,
                let contextType = CLSContextType(rawValue: typeValue) {
                type = contextType
            }
            
            var topic: CLSContextTopic?
            if let typeValue = context.topic {
                switch typeValue {
                case "math":
                    topic = CLSContextTopic.math
                case "science":
                    topic = CLSContextTopic.science
                case "literacyAndWriting":
                    topic = CLSContextTopic.literacyAndWriting
                case "worldLanguage":
                    topic = CLSContextTopic.worldLanguage
                case "socialScience":
                    topic = CLSContextTopic.socialScience
                case "computerScienceAndEngineering":
                    topic = CLSContextTopic.computerScienceAndEngineering
                case "artsAndMusic":
                    topic = CLSContextTopic.artsAndMusic
                case "healthAndFitness":
                    topic = CLSContextTopic.healthAndFitness
                default:
                    break
                }
            }
            
            var displayOrder = 0
            if let displayOrderValue = context.displayOrder {
                displayOrder = displayOrderValue
            }
            
            let element = ParsedXmlElement(
                title: context.title,
                type: type,
                topic: topic,
                identifier: context.identifierPath.last!,
                displayOrder: displayOrder,
                identifierPath: context.identifierPath
            )
            
            if xmlElements == nil {
                xmlElements = []
            }
            xmlElements!.insert(element)
            
            CLSDataStore.shared.contexts(matchingIdentifierPath: context.identifierPath, completion: { [weak self] (contexts, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.sendError(command: command, msg: "Could not create contexts", error: error)
                    } else {
                        self?.sendOK(command: command, msg: "Contexts have been initialized")
                    }
                }
            })
        } catch {
            sendError(command: command, msg: "Please provide a valid context object as the second parameter", error: error)
            return
        }
        
//        guard let identifierPath = command.argument(at: 1) as? [String], identifierPath.count > 0  else {
//            sendError(command: command, msg: "Please provide an identifier path as the second parameter", error: nil)
//            return
//        }
//
//        guard let title = command.argument(at: 2) as? String else {
//            sendError(command: command, msg: "Please provide a title path as the third parameter", error: nil)
//            return
//        }
    }
    
    // MARK: - remove all contexts
    @objc(removeContexts:) func removeContexts(_ command: CDVInvokedUrlCommand) {
        let predicate = NSPredicate(format: "%K < %@", CLSPredicateKeyPath.dateCreated as CVarArg, Date() as CVarArg)
        CLSDataStore.shared.contexts(matching: predicate) { [weak self] (contexts, error) in
            DispatchQueue.main.async {
                for context in contexts {
                    CLSDataStore.shared.remove(context)
                }
                
                CLSDataStore.shared.save(completion: { [weak self] (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self?.sendError(command: command, msg: nil, error: error)
                        } else {
                            self?.sendOK(command: command, msg: "\(contexts.count) contexts have been removed")
                        }
                    }
                })
            }
        }
    }
    
    // MARK: - remove context with identifier path
    @objc(removeContext:) func removeContext(_ command: CDVInvokedUrlCommand) {
        guard let identifierPath = command.argument(at: 0) as? [String] else {
            sendError(command: command, msg: "Please provide an identifier path array as the first parameter", error: nil)
            return
        }
        
        CLSDataStore.shared.mainAppContext.descendant(matchingIdentifierPath: identifierPath) { [weak self] (context, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.sendError(command: command, msg: nil, error: error)
                } else {
                    guard let context = context else {
                        self?.sendError(command: command, msg: "Could not find context for identifier path '\(identifierPath)'", error: nil)
                        return
                    }
                    
                    CLSDataStore.shared.remove(context)
                    
                    CLSDataStore.shared.save(completion: { [weak self] (error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                self?.sendError(command: command, msg: nil, error: error)
                            } else {
                                self?.sendOK(command: command, msg: "Context '\(identifierPath)' has been removed")
                            }
                        }
                    })
                }
            }
        }
    }

    // MARK: - start a new activity for a given context
    @objc(beginActivity:) func beginActivity(_ command: CDVInvokedUrlCommand) {
        guard let identifierPath = command.argument(at: 0) as? [String] else {
            sendError(command: command, msg: "Please provide an identifier path array as the first parameter", error: nil)
            return
        }
        
        let asNew = command.argument(at: 1) as? Bool ?? false
        
        CLSDataStore.shared.mainAppContext.descendant(matchingIdentifierPath: identifierPath) { [weak self] (context, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.sendError(command: command, msg: nil, error: error)
                } else {
                    guard let context = context else {
                        self?.sendError(command: command, msg: "Could not find context for identifier path '\(identifierPath)'", error: nil)
                        return
                    }
                    
                    context.becomeActive()
                    self?.activeContextIdentifier = identifierPath
                    
                    if asNew == false, let activity = context.currentActivity {
                        activity.start()
                        
                        self?.sendOK(command: command, msg: "Activity for context '\(identifierPath)' restarted")
                    } else {
                        context.createNewActivity()
                        
                        guard let activity = context.currentActivity else {
                            self?.sendError(command: command, msg: "Could not create activity", error: nil)
                            return
                        }
                        
                        activity.start()
                        
                        self?.sendOK(command: command, msg: "New Activity for context '\(identifierPath)' started")
                    }
                    
                    CLSDataStore.shared.save { (error) in
                        print(error ?? "no error while saving")
                    }
                }
            }
        }
    }
    
    // MARK: - set a progress range for an activtiy
    @objc(setProgressRange:) func setProgressRange(_ command: CDVInvokedUrlCommand) {
        guard let contextIdentifier = activeContextIdentifier else {
            sendError(command: command, msg: "Could not get active context. Please call startActivityForContext(identifier) first", error: nil)
            return
        }
        
        guard let startValue = command.argument(at: 0) as? Double else {
            sendError(command: command, msg: "Please provide a start value as the first parameter", error: nil)
            return
        }
        
        guard let endValue = command.argument(at: 1) as? Double else {
            sendError(command: command, msg: "Please provide a end value as the second parameter", error: nil)
            return
        }
        
        CLSDataStore.shared.mainAppContext.descendant(matchingIdentifierPath: contextIdentifier) { [weak self] (context, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.sendError(command: command, msg: nil, error: error!)
                } else {
                    guard let context = context else {
                        self?.sendError(command: command, msg: "Could not find context for identifier path '\(contextIdentifier)'", error: nil)
                        return
                    }
                    
                    guard let activity = context.currentActivity else {
                        self?.sendError(command: command, msg: "Could not get active context's activity", error: nil)
                        return
                    }
                    
                    guard activity.isStarted else {
                        self?.sendError(command: command, msg: "Activity is not started, call startActivityForContext(identifier) first", error: nil)
                        return
                    }
                    
                    activity.addProgressRange(fromStart: startValue, toEnd: endValue)
                    print("Progress (Range) set [\(contextIdentifier)]: \(Int(activity.progress * 100))%")
                    
                    self?.sendOK(command: command, msg: "Progress range has been set")
                }
            }
        }
    }
    
    // MARK: - set a progress for an activtiy
    @objc(setProgress:) func setProgress(_ command: CDVInvokedUrlCommand) {
        guard let contextIdentifier = activeContextIdentifier else {
            sendError(command: command, msg: "Could not get active context. Please call startActivityForContext(identifier) first", error: nil)
            return
        }

        guard let progressValue = command.argument(at: 0) as? Double else {
            sendError(command: command, msg: "Please provide a progress value as the first parameter", error: nil)
            return
        }
        
        CLSDataStore.shared.mainAppContext.descendant(matchingIdentifierPath: contextIdentifier) { [weak self] (context, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.sendError(command: command, msg: nil, error: error!)
                } else {
                    guard let context = context else {
                        self?.sendError(command: command, msg: "Could not find context for identifier path '\(contextIdentifier)'", error: nil)
                        return
                    }
                    
                    guard let activity = context.currentActivity else {
                        self?.sendError(command: command, msg: "Could not get active context's activity", error: nil)
                        return
                    }
                    
                    guard activity.isStarted else {
                        self?.sendError(command: command, msg: "Activity is not started, call startActivityForContext(identifier) first", error: nil)
                        return
                    }
                    
                    activity.progress = progressValue
                    print("Progress set [\(contextIdentifier)]: \(Int(activity.progress * 100))%")
                    
                    self?.sendOK(command: command, msg: "Progress range has been set")
                }
            }
        }
    }
    
    // MARK: - create and set a binary item for an activtiy
    @objc(setBinaryItem:) func setBinaryItem(_ command: CDVInvokedUrlCommand) {
        guard let contextIdentifier = activeContextIdentifier else {
            sendError(command: command, msg: "Could not get active context. Please call startActivityForContext(identifier) first", error: nil)
            return
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: command.argument(at: 0), options: .prettyPrinted) else {
            sendError(command: command, msg: "Please provide a binary object as the first parameter", error: nil)
            return
        }
        
        do {
            let item = try JSONDecoder().decode(CCKBinaryItem.self, from: data)
            
            guard item.type >= 0, item.type <= 2 else {
                sendError(command: command, msg: "Please provide a valid type (0, 1, or 2) as the third parameter", error: nil)
                return
            }
            
            let isPrimaryActivityItem = item.isPrimaryActivityItem ?? false
            
            CLSDataStore.shared.mainAppContext.descendant(matchingIdentifierPath: contextIdentifier) { [weak self] (context, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.sendError(command: command, msg: nil, error: error!)
                    } else {
                        guard let context = context else {
                            self?.sendError(command: command, msg: "Could not find context for identifier path '\(contextIdentifier)'", error: nil)
                            return
                        }
                        
                        guard let activity = context.currentActivity else {
                            self?.sendError(command: command, msg: "Could not get active context's activity", error: nil)
                            return
                        }
                        
                        guard activity.isStarted else {
                            self?.sendError(command: command, msg: "Activity is not started, call startActivityForContext(identifier) first", error: nil)
                            return
                        }
                        
                        let binaryItem = CLSBinaryItem(identifier: item.identifier, title: item.title, type: CLSBinaryValueType(rawValue: item.type)!)
                        binaryItem.value = item.isCorrect
                        
                        if isPrimaryActivityItem {
                            activity.primaryActivityItem = binaryItem
                        } else {
                            activity.addAdditionalActivityItem(binaryItem)
                        }
                        
                        print("Binary Item set  => \(item.title): \(binaryItem)")
                        
                        self?.sendOK(command: command, msg: "Binary item has been set")
                    }
                }
            }
        } catch {
            sendError(command: command, msg: "Please provide a valid binary item object as the first parameter", error: error)
            return
        }
    }
    
    // MARK: - set score item for an activtiy
    @objc(setScoreItem:) func setScoreItem(_ command: CDVInvokedUrlCommand) {
        guard let contextIdentifier = activeContextIdentifier else {
            sendError(command: command, msg: "Could not get active context. Please call startActivityForContext(identifier) first", error: nil)
            return
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: command.argument(at: 0), options: .prettyPrinted) else {
            sendError(command: command, msg: "Please provide a score object as the first parameter", error: nil)
            return
        }
        
        do {
            let item = try JSONDecoder().decode(CCKScoreItem.self, from: data)
            
            let isPrimaryActivityItem = item.isPrimaryActivityItem ?? false
            
            CLSDataStore.shared.mainAppContext.descendant(matchingIdentifierPath: contextIdentifier) { [weak self] (context, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.sendError(command: command, msg: nil, error: error!)
                    } else {
                        guard let context = context else {
                            self?.sendError(command: command, msg: "Could not find context for identifier path '\(contextIdentifier)'", error: nil)
                            return
                        }
                        
                        guard let activity = context.currentActivity else {
                            self?.sendError(command: command, msg: "Could not get active context's activity", error: nil)
                            return
                        }
                        
                        guard activity.isStarted else {
                            self?.sendError(command: command, msg: "Activity is not started, call startActivityForContext(identifier) first", error: nil)
                            return
                        }
                        
                        let scoreItem = CLSScoreItem(identifier: item.identifier, title: item.title, score: item.score, maxScore: item.maxScore)
                        
                        if isPrimaryActivityItem {
                            activity.primaryActivityItem = scoreItem
                        } else {
                            activity.addAdditionalActivityItem(scoreItem)
                        }
                        
                        print("Score Item set => \(item.title): \(scoreItem)")
                        
                        self?.sendOK(command: command, msg: "Score item has been set")
                    }
                }
            }
        } catch {
            sendError(command: command, msg: "Please provide a valid score item object as the first parameter", error: error)
            return
        }
    }
    
    // MARK: - set quantity item for an activtiy
    @objc(setQuantityItem:) func setQuantityItem(_ command: CDVInvokedUrlCommand) {
        guard let contextIdentifier = activeContextIdentifier else {
            sendError(command: command, msg: "Could not get active context. Please call startActivityForContext(identifier) first", error: nil)
            return
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: command.argument(at: 0), options: .prettyPrinted) else {
            sendError(command: command, msg: "Please provide a quantity object as the first parameter", error: nil)
            return
        }
        
        do {
            let item = try JSONDecoder().decode(CCKQuantityItem.self, from: data)
            
            let isPrimaryActivityItem = item.isPrimaryActivityItem ?? false
            
            CLSDataStore.shared.mainAppContext.descendant(matchingIdentifierPath: contextIdentifier) { [weak self] (context, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.sendError(command: command, msg: nil, error: error!)
                    } else {
                        guard let context = context else {
                            self?.sendError(command: command, msg: "Could not find context for identifier path '\(contextIdentifier)'", error: nil)
                            return
                        }
                        
                        guard let activity = context.currentActivity else {
                            self?.sendError(command: command, msg: "Could not get active context's activity", error: nil)
                            return
                        }
                        
                        guard activity.isStarted else {
                            self?.sendError(command: command, msg: "Activity is not started, call startActivityForContext(identifier) first", error: nil)
                            return
                        }
                        
                        let quantityItem = CLSQuantityItem(identifier: item.identifier, title: item.title)
                        quantityItem.quantity = item.quantity
                        
                        if isPrimaryActivityItem {
                            activity.primaryActivityItem = quantityItem
                        } else {
                            activity.addAdditionalActivityItem(quantityItem)
                        }
                        
                        print("Quantity Item set => \(item.title): \(quantityItem)")
                        
                        self?.sendOK(command: command, msg: "Quantity item has been set")
                    }
                }
            }
        } catch {
            sendError(command: command, msg: "Please provide a valid quantity item object as the first parameter", error: error)
            return
        }
    }
    
    // MARK: - stop activtiy
    @objc(endActivity:) func endActivity(_ command: CDVInvokedUrlCommand) {
        guard let contextIdentifier = activeContextIdentifier else {
            sendError(command: command, msg: "Could not get active context. Please call startActivityForContext(identifier) first", error: nil)
            return
        }
        
        CLSDataStore.shared.mainAppContext.descendant(matchingIdentifierPath: contextIdentifier) { [weak self] (context, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.sendError(command: command, msg: nil, error: error!)
                } else {
                    guard let context = context else {
                        self?.sendError(command: command, msg: "Could not find context for identifier path '\(contextIdentifier)'", error: nil)
                        return
                    }
                    
                    guard let activity = context.currentActivity else {
                        self?.sendError(command: command, msg: "Could not get active context's activity", error: nil)
                        return
                    }
                    
                    // print activity values
                    print("*** ACTIVITY END VALUES ***")
                    for item in activity.additionalActivityItems {
                        print("   => '\(item.identifier)' with title '\(item.title)': \(item)")
                    }
                    if let primaryItem = activity.primaryActivityItem {
                        print("   => '\(primaryItem.identifier)' with title '\(primaryItem.title)': \(primaryItem)")
                    }
                    print("   => progress: \(activity.progress)")
                    print("   => \(activity.duration) seconds elapsed.")
                    print("END: \(contextIdentifier)")
                    
                    activity.stop()
                    context.resignActive()
                    
                    self?.activeContextIdentifier = nil
                    
                    CLSDataStore.shared.save { (error) in
                        print(error ?? "no error while saving")
                    }
                    
                    self?.sendOK(command: command, msg: "Activity is stopped")
                }
            }
        }
    }
    
    func sendError(command: CDVInvokedUrlCommand, msg message: String?, error: Error?) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "CordovaClassKit Error: \(message ?? "") \(error != nil ? error!.localizedDescription : "")")
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }
    
    func sendOK(command: CDVInvokedUrlCommand, msg message: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "CordovaClassKit: \(message)")
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }
}

// - MARK: CLSDataStore Delegate
@available(iOS 11.3, *)
extension CCKApi: CLSDataStoreDelegate {
    func createContext(forIdentifier identifier: String, parentContext: CLSContext, parentIdentifierPath: [String]) -> CLSContext? {
        // Find a node in the model hiearchy based on the identifier path.
        let identifierPath = parentIdentifierPath + [identifier]
        
        guard let contextIdentifier = identifierPath.first,
            let elements = xmlElements,
            let element = elements.first(where: { $0.identifier == contextIdentifier }),
            let contextElement = descendant(element, matching: Array(identifierPath.suffix(identifierPath.count - 1))) else {
                print("CordovaClassKit Error: Could not init context for identifier '\(identifierPath.first ?? "NO_IDENTIFIER_FOUND")'")
                return nil
        }
        
        // Use the contextElement to create and customize a context.
        let context = CLSContext(type: contextElement.type, identifier: contextElement.identifier, title: contextElement.title)
        context.displayOrder = contextElement.displayOrder
        context.topic = contextElement.topic
        
        // Use custom URLs to locate activities.
        if let prefix = urlPrefix {
            if #available(iOS 11.4, *),
                let path = identifierPath.joined(separator: "/").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
                context.universalLinkURL = URL(string: prefix + path)
            }
        }

        print("Built context for \(contextElement.identifierPath)")

        return context
    }
    
    func descendant(_ parsedElement: ParsedXmlElement, matching identifierPath: [String]) -> ParsedXmlElement? {
        if let identifier = identifierPath.first,
            let elements = xmlElements {
            if let child = elements.first(where: { $0.identifier == identifier }) {
                return descendant(child, matching: Array(identifierPath.suffix(identifierPath.count - 1)))
            } else {
                return nil
            }
        } else {
            return parsedElement
        }
    }
}
