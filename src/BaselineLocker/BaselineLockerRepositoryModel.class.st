Class {
	#name : 'BaselineLockerRepositoryModel',
	#superclass : 'Object',
	#instVars : [
		'repository',
		'license',
		'baselines',
		'localFile',
		'owner',
		'repositoryName',
		'version',
		'licenseShorter'
	],
	#category : 'BaselineLocker',
	#package : 'BaselineLocker'
}

{ #category : 'initialization' }
BaselineLockerRepositoryModel >> = anObject [

	anObject == self ifTrue: [ ^ true ].
	anObject class == self class ifFalse: [ ^ false ].
	^ (anObject licence = self licence) and: [ anObject repository = self repository ]
	
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> addBaseline: aBaseline [

	baselines add: aBaseline
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> baselines [

	^ baselines
]

{ #category : 'initialization' }
BaselineLockerRepositoryModel >> initialize [

	baselines := OrderedCollection new
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> license [

	^ license
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> license: anObject [

	license := anObject
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> licenseShorter [

	^ licenseShorter
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> licenseShorter: anObject [

	licenseShorter := anObject
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> localFile [
	^ localFile
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> localFile: anObject [

	localFile := anObject
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> repository [

	^ repository
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> repository: anObject [

	repository := anObject.
	self updateOwnerNameAndVersion.
	self updateLocalFile.
	self updateLicense
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> repositoryName [
	^ repositoryName
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> updateLicense [

	| licenseFile |
	licenseFile := self localFile files select: [ :each |
		               each basename asLowercase beginsWith: 'license' ].
	licenseFile ifEmpty: [
		licenseShorter := license := 'Not found'.
		^ self ].
	licenseFile size > 1 ifTrue: [
		licenseShorter := license := 'Too many license files'.
		^ self ].
	license := licenseFile first contents.

	licenseShorter := license lines first
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> updateLocalFile [

	| expectedName myRepository |
	expectedName := self repositoryName.

	myRepository := IceRepository registry
		                detect: [ :each |
		                each name = expectedName ]
		                ifNone: [
			                self error:
				                ('Did not find any repository named ''{1}'' in Iceberg (case insensitive). Alexandrie tests require it to access resources.'
					                 format: { expectedName }) ].

	localFile := myRepository location
]

{ #category : 'accessing' }
BaselineLockerRepositoryModel >> updateOwnerNameAndVersion [

	| array repoAndVersion |
	array := ($/ split: (self repository allButFirst: 9)) first: 2.
	owner := array at: 1.
	repoAndVersion := ($: split: (array at: 2)).
	repositoryName := repoAndVersion first.
	repoAndVersion size = 1 ifTrue: [ ^ self ].
	version := ($: split: (array at: 2)) second.

]
