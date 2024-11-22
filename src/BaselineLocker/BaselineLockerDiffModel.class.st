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

{ #category : 'accessing' }
BaselineLockerDiffModel >> repositories [

	^ repositories
]

{ #category : 'accessing' }
BaselineLockerDiffModel >> sources [

	^ sources
]
