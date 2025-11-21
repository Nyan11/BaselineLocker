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
BaselineLockerDiffModel >> prettyPrintInBaselineCode [

	| configName blocInside |
	self repositories ifEmpty: [ ^ '' ].
	
	configName := self baseline name allButFirst: 10.
	blocInside := ''.
	self loads size > 1 ifTrue: [ blocInside := blocInside , '<t><t>self flag: #CHOOSE. "Choose one of the loads config"<r>' expandMacros ].
	self loads keysAndValuesDo: [ :key :value |
					| newLoadLine |
					key
						ifNil: [
								newLoadLine := '<t><t>"loads default" "<1s>"<r>'
									               expandMacrosWith:
									               (Character space join: value) ]
						ifNotNil: [
								newLoadLine := '<t><t>spec loads: <1p>. "<2s>"<r>'
									               expandMacrosWith: key
									               with: (Character space join: value).
								blocInside := blocInside , newLoadLine ] ].
	self repositories size > 1 ifTrue: [ blocInside := blocInside , '<t><t>self flag: #CHOOSE. "Choose one of the repositories config"<r>' expandMacros ].
			self repositories keysAndValuesDo: [ :key :value |
					| newRepoLine |
					newRepoLine := '<t><t>spec repository: <1p>. "<2s> -> (<3s>)"<r>'
						               expandMacrosWith: key
						               with: value licenseShorter
						               with: (Character space join: value baselines).
					blocInside := blocInside , newRepoLine ].

	^ '<t>spec baseline: ''<1s>'' with: [<r><2s><t>].<r><r>' expandMacrosWith: configName with: blocInside
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
