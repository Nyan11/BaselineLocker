Class {
	#name : 'BaselineLocker',
	#superclass : 'SpPresenter',
	#instVars : [
		'baselinesInput',
		'dependenciesTable',
		'errorLabel',
		'copyBaselineButton',
		'copyMarkdownButton'
	],
	#category : 'BaselineLocker',
	#package : 'BaselineLocker'
}

{ #category : 'baselines' }
BaselineLocker class >> baselineModelScriptForCollectionOfBaselines: aCollectionOfBaselines [

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
							dependenciesModels := dependenciesProjects collect: [
									                      :dependency |
									                      | model |
									                      model := BaselineLockerDiffModel new.
									                      model addSource: target.
									                      model baseline:
										                      (Smalltalk globals at:
											                       dependency constructClassName
												                       asSymbol).
									                      model
										                      addRepositories:
										                      dependency repositories list first
											                      name
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
												each repositories keysDo: [ :repo |
													model addRepositories: repo fromSource: target ].
												each loads keysDo: [ :repo |
													model addLoads: repo fromSource: target ] ]
										ifAbsentPut: each ].
							foundBaselines
								at: target
								put: dependenciesClasses asOrderedCollection.
							todos addAll: dependenciesClasses ] ] ].

	count >= maxBaselines ifTrue: [ Error new signal ].

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
							each remove: leaf ifAbsent: [ ] ].
						allBaselineToAdd removeKey: leaf ifAbsent: [ ] ].
				orderedBaselines addAll:
					(leaves keys reject: [ :each | orderedBaselines includes: each ]) ].

	count >= maxBaselines ifTrue: [ Error new signal ].

	^ orderedBaselines collect: [ :each |
			  modelDictionary at: each ifAbsentPut: [
					  BaselineLockerDiffModel new
						  baseline: each;
						  yourself ] ]
]

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

	| dependencies |
	dependencies := [
		                self class
			                baselineModelScriptForCollectionOfBaselines:
			                aCollectionOfBaselines ]
		                on: Error
		                do: [ ^ self errorInDependencies ].
	self dependencies: dependencies
]

{ #category : 'as yet unclassified' }
BaselineLocker >> computeLicences [
	dependenciesTable items do: [ :each | each repositories values do: #updateLicence ].
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
			newRepoLine := '<t>spec repository: <1p>. "<2s> -> (<3s>)"<r>'
				               expandMacrosWith: key
				 				   with: (value licenseShorter)
				               with: (Character space join: value baselines)
								  .
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
		  add: baselinesInput expand: false;
		  add: (SpBoxLayout newHorizontal
				   spacing: 4;
				   add: copyBaselineButton expand: true;
				   add: copyMarkdownButton expand: true;
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

{ #category : 'TOREMOVE' }
BaselineLocker >> initialExtent [

	^ 600 @ 400.
]

{ #category : 'initialization' }
BaselineLocker >> initializeBaselinesInput [.
	
	baselinesInput := SpTextInputFieldPresenter new
		                  help:
			                  'Input the baselines you want to tags separate by a ".".';
		                  whenSubmitDo: [ :text |
			                  self computeBaselineClassesFrom: text ];
		                  yourself.
]

{ #category : 'initialization' }
BaselineLocker >> initializeCopyButton [

	copyBaselineButton := SpButtonPresenter new
		                      icon:
			                      (Smalltalk ui icons iconNamed: #smallCopy);
		                      label: 'as Pharo Code';
		                      help:
			                      'Copy in the clipboard the current Baseline fix.';
		                      action: [
				                      self copyCurrent.
				                      self inform: 'Copy code to clipboard' ];
		                      yourself.
	copyMarkdownButton := SpButtonPresenter new
		                      icon:
			                      (Smalltalk ui icons iconNamed: #smallCopy);
		                      label: 'as Markdown Code';
		                      help:
			                      'Copy in the clipboard the current Baseline fix.';
		                      action: [
				                      Clipboard clipboardText:
						                      ((dependenciesTable items collect:
								                        #prettyPrintInMarkdown) reduce: [ :a :b |
								                       a , b ]).
				                      self inform: 'Copy markdow to clipboard' ];
		                      yourself
]

{ #category : 'initialization' }
BaselineLocker >> initializeDependenciesTable [

	| refNumberColumn nameColumn loadsColumn repositoryColumn licenseColumn |
	dependenciesTable := SpTablePresenter new
		                     beResizable;
		                     contextMenu:
			                     (SpMenuPresenter new addGroup: [ :group |
					                      group addItem: [ :item |
							                      item
								                      name: 'Browse';
								                      icon:
									                      (Smalltalk ui icons iconNamed:
											                       #nautilus);
								                      action: [
									                      dependenciesTable selectedItem baseline
										                      browse ] ].
					                      group
						                      addItem: [ :item |
							                      item
								                      name: 'Inspect';
								                      icon:
									                      (Smalltalk ui icons iconNamed:
											                       #smallInspectIt);
								                      action: [
									                      dependenciesTable selectedItem inspect ] ];
						                      addItem: [ :item |
							                      item
								                      name: 'Inspect License';
								                      icon:
									                      (Smalltalk ui icons iconNamed: #history);
								                      action: [
									                      dependenciesTable selectedItem
										                      repositories values first license
										                      inspect ] ] ]);
		                     yourself.
	refNumberColumn := SpStringTableColumn new
		                   title: '#';
		                   evaluated: [ :model |
			                   model sources size printString ];
		                   width: 16;
		                   yourself.
	nameColumn := SpStringTableColumn new
		              title: 'Name';
		              evaluated: [ :model | model baseline printString ];
		              beExpandable;
		              yourself.
	loadsColumn := SpStringTableColumn new
		               title: 'Loads';
		               evaluated: [ :model |
			               model loads ifEmpty: [ '' ] ifNotEmpty: [ :loads |
					               loads size = 1
						               ifTrue: [ loads keys first ]
						               ifFalse: [ 'Conflicts' ] ] ];
		               beExpandable;
		               width: 120;
		               yourself.
	repositoryColumn := SpStringTableColumn new
		                    title: 'Repositories';
		                    evaluated: [ :model |
			                    model repositories
				                    ifEmpty: [ '' ]
				                    ifNotEmpty: [ :rep |
					                    rep size = 1
						                    ifTrue: [ rep keys first ]
						                    ifFalse: [ 'Conflicts' ] ] ];
		                    beExpandable;
		                    yourself.
	licenseColumn := SpStringTableColumn new
		                 title: 'License in Iceberg';
		                 evaluated: [ :model |
			                 model repositories
				                 ifEmpty: [ '' ]
				                 ifNotEmpty: [ :rep |
					                 rep values first licenseShorter ] ];
		                 beExpandable;
		                 width: 120;
		                 yourself.
	dependenciesTable addColumns: {
			refNumberColumn.
			nameColumn.
			loadsColumn.
			repositoryColumn.
			licenseColumn }
]

{ #category : 'initialization' }
BaselineLocker >> initializeErrorLabel [.

	errorLabel := SpLabelPresenter new.
	
]

{ #category : 'initialization' }
BaselineLocker >> initializePresenters [

	super initializePresenters.
	self initializeErrorLabel.
	self initializeBaselinesInput.
	self initializeDependenciesTable.
	self initializeCopyButton.
	
]

{ #category : 'initialization' }
BaselineLocker >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Baseline Locker';
		initialExtent: self initialExtent
]
