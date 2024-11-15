Class {
	#name : 'BaselineLockerModel',
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
BaselineLockerModel >> addLoads: anObject fromSource: aBaseline [

	loads
		at: anObject
		ifPresent: [ :col | col add: aBaseline ]
		ifAbsentPut: [ OrderedCollection with: aBaseline ]
]

{ #category : 'initialization' }
BaselineLockerModel >> addRepositories: anObject fromSource: aBaseline [

	repositories at: anObject ifPresent: [ :col | col add: aBaseline ] ifAbsentPut: [ OrderedCollection with: aBaseline ].
]

{ #category : 'initialization' }
BaselineLockerModel >> addSource: anObject [

	sources add: anObject
]

{ #category : 'accessing' }
BaselineLockerModel >> baseline [

	^ baseline
]

{ #category : 'accessing' }
BaselineLockerModel >> baseline: anObject [

	baseline := anObject
]

{ #category : 'initialization' }
BaselineLockerModel >> initialize [

	super initialize.
	sources := OrderedCollection new.
	repositories := Dictionary new.
	loads := Dictionary new
]

{ #category : 'accessing' }
BaselineLockerModel >> loads [

	^ loads
]

{ #category : 'accessing' }
BaselineLockerModel >> repositories [

	^ repositories
]

{ #category : 'accessing' }
BaselineLockerModel >> sources [

	^ sources
]
