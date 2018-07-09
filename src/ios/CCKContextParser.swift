//
//  ContextParser.swift
//  ClassKitDemo
//
//  Created by Baar, Sebastian on 03.07.18.
//  Copyright © 2018 Baar, Sebastian. All rights reserved.
//

// swiftlint:disable trailing_whitespace identifier_name function_body_length line_length

import Foundation
import ClassKit

enum ContextParserError: Error {
    case XMLFileNotFound
    case XMLParserError(Error)
    case XMLParseError
    case XMLParserInitWithContents(URL)
    case UnexpectedElementName(String)
}

@available(iOS 11.3, *)
struct ParsedXmlElement: Hashable {
    let title: String
    let type: CLSContextType
    let topic: CLSContextTopic?
    let identifier: String
    let displayOrder: Int
    let identifierPath: [String]
    
    var hashValue: Int {
        let uniqueValue = identifierPath + [identifier]
        return String(describing: uniqueValue).hashValue
    }
    
    static func == (lhs: ParsedXmlElement, rhs: ParsedXmlElement) -> Bool {
        return lhs.identifier == rhs.identifier &&
            lhs.identifierPath == rhs.identifierPath
    }
}

@available(iOS 11.3, *)
class CCKContextParser: NSObject {
    typealias ContextParserCallback = (ContextParserError?, Set<ParsedXmlElement>?) -> Void
    
    final let CONTEXT_ELEMENT_NAME = "context"
    final let ROOT_ELEMENT_NAME = "root"
    
    var depth: Int = 0
    var parsedXmlElements: Set<ParsedXmlElement> = []
    var error: ContextParserError?
    
    func parse(fileName: String, _ completionHandler: @escaping ContextParserCallback) throws {
        guard let path = Bundle.main.url(forResource: fileName, withExtension: "xml") else {
            throw ContextParserError.XMLFileNotFound
        }
        
        guard let parser = XMLParser(contentsOf: path) else {
            throw ContextParserError.XMLParserInitWithContents(path)
        }
        
        parser.delegate = self
        
        if parser.parse() {
            guard error != nil else {
                completionHandler(error, nil)
                return
            }
            completionHandler(nil, parsedXmlElements)
        } else {
            completionHandler(ContextParserError.XMLParseError, nil)
        }
    }
}

@available(iOS 11.3, *)
extension CCKContextParser: XMLParserDelegate {
    func parserDidStartDocument(_ parser: XMLParser) {
        depth = 0
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        error = ContextParserError.XMLParserError(parseError)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        
        if elementName == CONTEXT_ELEMENT_NAME {
            createXmlObject(attributeDict)
            depth += 1
        } else {
            error = ContextParserError.UnexpectedElementName(elementName)
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    private func createXmlObject(_ attributeDict: [String: String]) {
        var title = String()
        var identifier = String()
        var displayOrder = 0
        var topic: CLSContextTopic? = nil
        var identifierPath = [String]()
        var contextType: CLSContextType = .none

        for attr in attributeDict {
            switch attr.key {
            case "title":
                title = attr.value
            case "displayOrder":
                if let order = Int(attr.value) {
                    displayOrder = order
                }
            case "identifierPath":
                if let value = String(attr.value), value != "" {
                    identifierPath = value.components(separatedBy: ",").map({ $0.trimmingCharacters(in: .whitespaces) })
                    identifier = identifierPath.last!
                }
            case "type":
                if let value = Int(attr.value),
                    let type = CLSContextType(rawValue: value) {
                    contextType = type
                }
            case "topic":
                if let value = String(attr.value), value != "" {
                    switch value {
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
            default:
                break
            }
        }
        parsedXmlElements.insert(
            ParsedXmlElement(
                title: title,
                type: contextType,
                topic: topic,
                identifier: identifier,
                displayOrder: displayOrder,
                identifierPath: identifierPath)
        )
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == CONTEXT_ELEMENT_NAME {
            depth -= 1
        } else if elementName != ROOT_ELEMENT_NAME {
            error = ContextParserError.UnexpectedElementName(elementName)
        }
    }
}
