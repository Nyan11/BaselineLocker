Class {
	#name : 'BaselineLocker',
	#superclass : 'SpPresenter',
	#instVars : [
		'baselinesInput',
		'dependenciesTable',
		'copyButton',
		'errorLabel'
	],
	#category : 'BaselineLocker',
	#package : 'BaselineLocker'
}

{ #category : 'private' }
BaselineLocker class >> launch [

	<script>
	self new open
]

{ #category : 'accessing' }
BaselineLocker >> baselinesInput [

	^ baselinesInput
]

{ #category : 'initialization' }
BaselineLocker >> computeBaselineClassesFrom: text [

	| classes |
	classes := ($. split: text) collect: [ :each |
		           Smalltalk globals
			           at: each trim asSymbol
			           ifPresent: [ :class |
				           (class inheritsFrom: BaselineOf)
					           ifTrue: [ class ]
					           ifFalse: [ ^ self errorNotABaseline: each trim ] ]
			           ifAbsent: [ ^ self errorNoClassFound: each trim ] ].
	self computeDependenciesFrom: classes
]

{ #category : 'initialization' }
BaselineLocker >> computeDependenciesFrom: aCollectionOfBaselines [

	| foundBaselines count todos dependenciesModels dependenciesClasses orderedBaselines allBaselineToAdd dependenciesProjects modelDictionary maxBaselines |
	maxBaselines := 500.
	foundBaselines := Dictionary new.
	modelDictionary := Dictionary new.
	count := 1.

	aCollectionOfBaselines do: [ :bl |
		todos := Set with: bl.
		[ todos isNotEmpty and: [ count < maxBaselines ] ] whileTrue: [
			| target |
			target := todos anyOne.
			count := count + 1.
			todos remove: target.
			(foundBaselines includesKey: target) ifFalse: [
				dependenciesProjects := target version projects select: [
					                        :dependencyProject |
					                        | baselineClassName |
					                        baselineClassName := dependencyProject
						                                             constructClassName.
					                        baselineClassName
						                        ifNil: [ false ]
						                        ifNotNil: [ :string |
						                        Smalltalk globals includesKey:
							                        string asSymbol ] ].
				dependenciesModels := dependenciesProjects collect: [ :dependency |
					                      | model |
					                      model := BaselineLockerModel new.
					                      model addSource: target.
					                      model baseline:
						                      (Smalltalk globals at:
							                       dependency constructClassName asSymbol).
					                      model
						                      addRepositories:
						                      dependency repositories list first name
						                      fromSource: target.
					                      model
						                      addLoads: dependency loads
						                      fromSource: target ].
				dependenciesClasses := (dependenciesModels collect: [ :each |
					                        each baseline ]) asSet.
				dependenciesModels do: [ :each |
					modelDictionary
						at: each baseline
						ifPresent: [ :model |
							model addSource: target.
							each repositories keys do: [ :repo | model addRepositories: repo fromSource: target ].
							each loads keys do: [ :repo | model addLoads: repo fromSource: target ]
							]
						ifAbsentPut: each ].
				foundBaselines
					at: target
					put: dependenciesClasses asOrderedCollection.
				todos addAll: dependenciesClasses ] ] ].

	count >= maxBaselines ifTrue: [ ^ self errorInDependencies ].

	orderedBaselines := OrderedCollection new.
	allBaselineToAdd := foundBaselines copy.

	count := 1.
	[ allBaselineToAdd isNotEmpty and: [ count < maxBaselines ] ]
		whileTrue: [
			| leaves |
			count := count + 1.
			leaves := foundBaselines select: [ :each | each value isEmpty ].
			leaves keysDo: [ :leaf |
				allBaselineToAdd valuesDo: [ :each |
					each remove: leaf ifAbsent: [  ] ].
				allBaselineToAdd removeKey: leaf ifAbsent: [  ] ].
			orderedBaselines addAll:
				(leaves keys reject: [ :each | orderedBaselines includes: each ]) ].

	count >= maxBaselines ifTrue: [ ^ self errorInDependencies ].

	self dependencies: (orderedBaselines collect: [ :each |
			 modelDictionary at: each ifAbsentPut: [
				 BaselineLockerModel new
					 baseline: each;
					 yourself ] ])
]

{ #category : 'copying' }
BaselineLocker >> copyCurrent [

	| text |
	text := ''.
	dependenciesTable items do: [ :each |
		| configName insideBloc |
		configName := each baseline name allButFirst: 10.
		insideBloc := ''.
		each loads size > 1 ifTrue: [
			insideBloc := insideBloc
			              ,
				              '<t>self flag: #CHOOSE. "Choose one of the loads config"<r>'
					              expandMacros ].
		each loads keysAndValuesDo: [ :key :value |
			| newLoadLine |
			key
				ifNil: [
					newLoadLine := '<t>"loads default" "<1s>"<r>' expandMacrosWith:
						               (Character space join: value) ]
				ifNotNil: [
					newLoadLine := '<t>spec loads: <1p>. "<2s>"<r>'
						               expandMacrosWith: key
						               with: (Character space join: value).
					insideBloc := insideBloc , newLoadLine ] ].
		each repositories size > 1 ifTrue: [
			insideBloc := insideBloc
			              ,
				              '<r><t>self flag: #CHOOSE. "Choose one of the repositories config"<r>'
					              expandMacros ].
		each repositories keysAndValuesDo: [ :key :value |
			| newRepoLine |
			newRepoLine := '<t>spec repository: <1p>. "<2s>"<r>'
				               expandMacrosWith: key
				               with: (Character space join: value).
			insideBloc := insideBloc , newRepoLine ].
		each sources isEmpty ifTrue: [
			text := text
			        ,
				        'self flag: #MANUALLY. "No config found. Either do mannually or remove"<r>'
					        expandMacros ].
		text := text , 'spec baseline: <1p> with: [<r><2s>].<r><r>'
			        expandMacrosWith: configName
			        with: insideBloc ].

	Clipboard clipboardText: text
]

{ #category : 'layout' }
BaselineLocker >> defaultLayout [

	^ SpBoxLayout newVertical
		  spacing: 4;
		  add: (SpBoxLayout newHorizontal
				   spacing: 4;
				   add: baselinesInput expand: true;
				   add: copyButton expand: false;
				   yourself)
		  expand: false;
		  add: errorLabel expand: false;
		  add: dependenciesTable expand: true;
		  yourself
]

{ #category : 'initialization' }
BaselineLocker >> dependencies: aCollectionOfBaselineModels [

	dependenciesTable items: aCollectionOfBaselineModels.
	errorLabel label: ''
]

{ #category : 'as yet unclassified' }
BaselineLocker >> errorInDependencies [

	self dependencies: {  }.
	errorLabel label: ('There is an error in the baseline dependies (cycles ?)')
]

{ #category : 'as yet unclassified' }
BaselineLocker >> errorNoClassFound: aString [

	self dependencies: {  }.
	errorLabel label: ('<1s> is not a class' expandMacrosWith: aString)
]

{ #category : 'as yet unclassified' }
BaselineLocker >> errorNotABaseline: aString [

	self dependencies: {  }.
	errorLabel label: ('<1s> is not a baseline' expandMacrosWith: aString)
]

{ #category : 'initialization' }
BaselineLocker >> initializePresenters [

	super initializePresenters.
	errorLabel := SpLabelPresenter new.
	baselinesInput := SpTextInputFieldPresenter new
		                  help:
			                  'Input the baselines you want to tags separate by a ".".';
		                  whenSubmitDo: [ :text |
			                  self computeBaselineClassesFrom: text ];
		                  yourself.

	dependenciesTable := SpTablePresenter new
		                     contextMenu:
			                     (SpMenuPresenter new addGroup: [ :group |
					                      group addItem: [ :item |
							                      item
								                      name: 'Browse';
								                      action: [
									                      dependenciesTable selectedItem baseline
										                      browse ] ].
					                      group addItem: [ :item |
						                      item
							                      name: 'Inspect';
							                      action: [
								                      dependenciesTable selectedItem inspect ] ] ]);
		                     yourself.
	dependenciesTable addColumn: (SpStringTableColumn new
			 title: 'Sources';
			 evaluated: [ :model | model sources size printString ];
			 yourself).
	dependenciesTable addColumn: (SpStringTableColumn new
			 title: 'Name';
			 evaluated: [ :model | model baseline printString ];
			 yourself).
	dependenciesTable addColumn: (SpStringTableColumn new
			 title: 'Repositories';
			 evaluated: [ :model |
				 model repositories ifEmpty: [ '' ] ifNotEmpty: [ :rep | rep size = 1 ifTrue: [ rep keys first ] ifFalse: [ 'Conflicts' ] ] ];
			 yourself).
	dependenciesTable addColumn: (SpStringTableColumn new
			 title: 'Loads';
			 evaluated: [ :model |
				 model loads ifEmpty: [ '' ] ifNotEmpty: [ :loads | loads size = 1 ifTrue: [ loads keys first ] ifFalse: [ 'Conflicts' ] ] ];
			 yourself).
	copyButton := SpButtonPresenter new
		              icon: (Smalltalk ui icons iconNamed: #smallCopy);
		              help:
			              'Copy in the clipboard the current Baseline fix.';
						 action: [ self copyCurrent ];
		              yourself
]
