Class {
	#name : 'BaselineOfBaselineLocker',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfBaselineLocker',
	#package : 'BaselineOfBaselineLocker'
}

{ #category : 'baselines' }
BaselineOfBaselineLocker >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec package: 'BaselineLocker' ]
]
