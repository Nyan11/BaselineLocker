Extension { #name : 'BaselineOf' }

{ #category : '*BaselineLocker' }
BaselineOf class >> quiclyCreateFixedVersion [

	| editor |
	editor := BaselineLocker new
		          computeDependenciesFrom: { self };
		          yourself.
	editor baselinesInput text: self name.
	editor open
]
