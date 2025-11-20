Class {
	#name : 'BaselineLockerDiffModel',
	#superclass : 'Object',
	#instVars : [
		'baseline',
		'repositories',
		'loads',
		'sources'
	],
	#category : 'BaselineLocker',
	#package : 'BaselineLocker'
}

{ #category : 'initialization' }
BaselineLockerDiffModel >> addLoads: anObject fromSource: aBaseline [

	loads
		at: anObject
		ifPresent: [ :col | col add: aBaseline ]
		ifAbsentPut: [ OrderedCollection with: aBaseline ]
]

{ #category : 'initialization' }
BaselineLockerDiffModel >> addRepositories: anObject fromSource: aBaseline [

	repositories
		at: anObject
		ifPresent: [ :repositoryLModel | repositoryLModel addBaseline: aBaseline ]
		ifAbsentPut: [ BaselineLockerRepositoryModel new repository: anObject; addBaseline: aBaseline; yourself ]
]

{ #category : 'initialization' }
BaselineLockerDiffModel >> addSource: anObject [

	sources add: anObject
]

{ #category : 'accessing' }
BaselineLockerDiffModel >> baseline [

	^ baseline
]

{ #category : 'accessing' }
BaselineLockerDiffModel >> baseline: anObject [

	baseline := anObject
]

{ #category : 'initialization' }
BaselineLockerDiffModel >> initialize [

	super initialize.
	sources := OrderedCollection new.
	repositories := Dictionary new.
	loads := Dictionary new
]

{ #category : 'accessing' }
BaselineLockerDiffModel >> loads [

	^ loads
]

{ #category : 'as yet unclassified' }
BaselineLockerDiffModel >> prettyPrintInMarkdown [

	| allPossibleStrings accumulator |
	self repositories ifEmpty: [ ^ '' ].
	allPossibleStrings := (self repositories values collect:
		                       #prettyPrintInMarkdown) asOrderedCollection
		                      removeDuplicates.
	allPossibleStrings size = 1 ifTrue: [ ^ allPossibleStrings first ].
	accumulator := ''.
	allPossibleStrings do: [ :each | accumulator := accumulator , each ].
	^ '============<r>Choose one between all:<r><r><1s><r>============<r>'
		  expandMacrosWith: accumulator
]

{ #category : 'accessing' }
BaselineLockerDiffModel >> repositories [

	^ repositories
]

{ #category : 'accessing' }
BaselineLockerDiffModel >> sources [

	^ sources
]
