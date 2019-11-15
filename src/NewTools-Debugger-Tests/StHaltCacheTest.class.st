Class {
	#name : #StHaltCacheTest,
	#superclass : #StHaltAndBreakpointControlTest,
	#category : #'NewTools-Debugger-Tests'
}

{ #category : #'testing - halts cache' }
StHaltCacheTest >> testAddingHaltToMethod [
	|nodeCacheForSimpleHalt originalNodeCacheSize|
	nodeCacheForSimpleHalt := cache nodeCacheForSelector: #mHalt.
	originalNodeCacheSize := nodeCacheForSimpleHalt size.
	
	self testClass compile: 'mHalt self halt. self halt'.
	nodeCacheForSimpleHalt := cache nodeCacheForSelector: #mHalt.
	self assert: nodeCacheForSimpleHalt size equals: originalNodeCacheSize + 1.
	(self testClass >> #mHalt) ast statements 
		do:[:node| self assert: (nodeCacheForSimpleHalt includes: node)].
	self assert: 
			(cache methodsWithHalts keys select:[:methodSelector| methodSelector = #mHalt]) size 
			equals: 1
		

]

{ #category : #accessors }
StHaltCacheTest >> testClass [
	^ StBreakpointCacheDummyClassWithHalts
]

{ #category : #'testing - cache building' }
StHaltCacheTest >> testInitialCacheBuild [
	self assert: cache methodsWithHalts size >= 6.
	self testClass methods
		do:
			[ :method | 
			|haltNode nodeCache|
			haltNode := method ast statements first.
					
			self assert: (cache methodsWithHalts keys includes: method selector).
			
			nodeCache := cache nodeCacheForSelector: method selector.
			self assert: nodeCache size equals: 1.
			self assert: nodeCache asOrderedCollection first == haltNode ].
	
]

{ #category : #'testing - halts cache' }
StHaltCacheTest >> testMethodWithHaltRemoval [
	|methodCacheForSimpleHalt |
	methodCacheForSimpleHalt := cache methodsWithHalts size.
	
	self testClass removeSelector: #mHalt.	
	self assert: cache methodsWithHalts size equals: methodCacheForSimpleHalt - 1.
	self assert: 
		(cache methodsWithHalts keys select:[:methodSelector| methodSelector = #mHalt]) isEmpty
]

{ #category : #'testing - halts cache' }
StHaltCacheTest >> testNewMethodWithHalt [
	|methodCacheForSimpleHalt haltNode|
	methodCacheForSimpleHalt := cache methodsWithHalts size.
	
	self testClass compile: 'mHalt2 self halt.'.	
	haltNode := (self testClass>>#mHalt2) ast statements first.	
	
	self assert: cache methodsWithHalts size equals: methodCacheForSimpleHalt + 1.
	self assert: (cache nodeCacheForSelector: #mHalt2) size equals: 1.
	self assert: (cache nodeCacheForSelector: #mHalt2) asOrderedCollection first == haltNode.

]

{ #category : #'testing - halts cache' }
StHaltCacheTest >> testRemoveAllHaltsFromMethod [
	|methodCacheForSimpleHalt |
	methodCacheForSimpleHalt := cache methodsWithHalts size.
	
	self testClass compile: 'mHalt ^self'.	
	self assert: cache methodsWithHalts size equals: methodCacheForSimpleHalt - 1.
	self assert: 
		(cache methodsWithHalts keys select:[:methodSelector| methodSelector = #mHalt]) isEmpty
]