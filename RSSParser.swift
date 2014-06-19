//
//  RSSParser.swift
//
//  Created by Evan Dekhayser on 6/10/14.
//  Copyright (c) 2014 Evan Dekhayser. All rights reserved.
//

import UIKit

protocol RSSParserDelegate{
	func parserDidFailWithError(error: NSError) -> Void
	func parserDidCompleteSuccessfully(posts: Array<Dictionary<String,String>>) -> Void
	func parserDidBegin() -> Void
}

class RSSParser: NSObject, NSXMLParserDelegate{
	
	var parser: NSXMLParser = NSXMLParser()
	var posts: Array <Dictionary <String, String> > = []
	var elements: Dictionary <String, String> = [:]
	var element: String = ""
	var title: String = ""
	var	date: String = ""
	var	summary: String = ""
	var link: String = ""
	var delegate: XMLParserDelegate?
	
	init(){
		super.init()
	}
	
	convenience init(URL url: NSURL,delegate newDelegate: XMLParserDelegate?){
		self.init()
		if let newValue = newDelegate{
			delegate = newValue
		}
		beginParsing(url)
	}
	
	func rssPosts() -> Array< Dictionary <String, String> >{
		return self.posts
	}
	
	func beginParsing(url: NSURL){
		parser = NSXMLParser(contentsOfURL: url)
		posts = []
		
		parser.shouldProcessNamespaces = false
		parser.shouldReportNamespacePrefixes = false
		parser.shouldResolveExternalEntities = false
		parser.delegate = self
		parser.parse()
	}
	
	// #pragma mark NSXMLParser Delegate Methods
	
	func parserDidStartDocument(parser: NSXMLParser!){
		self.delegate?.parserDidBegin()
	}
	
	func parserDidEndDocument(parser: NSXMLParser!){
		self.delegate?.parserDidCompleteSuccessfully(self.posts)
	}
	
	func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!){
		self.delegate?.parserDidFailWithError(parseError)
	}
	
	func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName: String!, attributes attributeDict: NSDictionary!){
		
		element = elementName
		
		if elementName == "item"{
			elements = [:]
			title = ""
			date = ""
			summary = ""
			link = ""
		}
	
	}
	
	func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!){
		if elementName == "item"{
			elements["title"] = title
			elements["date"] = date
			elements["summary"] = summary
			elements["link"] = link
			
			posts += elements
		}
	}
	
	func parser(parser: NSXMLParser!, foundCharacters string: String!){
		switch element{
			case "title":
				title += string
			case "pubDate":
				date += string
			case "description":
				summary += string
			case "link":
				link += string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		default:
			break
		}
	}
}

