# BaselineLocker

Create the body of a depencies baseline method.
Use this project to simply create fixed version of a project.

## installation

```st
Metacello new
	baseline: 'BaselineLocker';
	repository: 'github://Nyan11/BaselineLocker:master/src';
	load
```

## usage

In a playground:
```st
"To open from an existing baseline:"
BaselineOfPyramid quiclyCreateFixedVersion.

"To open on no baseline:"
BaselineLocker new open.
```

![image](https://github.com/user-attachments/assets/f78d18f6-9304-4257-80c3-4ab19ddd0c0e)

In the input field on top you can enter multiple Baselines.
For example: `BaselineOfPyramid . BaselineOfSton . BaselineOfToplo`.

In the table:
- sources: Is the number of baselines and sub-baselines that reference this project.
- name: Is the name of the baseline.
- repositories: Is the targeted repository inside the baselines and sub-baselines ('Conflict' when multiple baseline want to change the repository.
- loads: Is the load project for this baseline. If empty then it is the default load, if 'Conflict' multiple config possible.

You can right-clic on the table to browse a specific baseline or inspect the model (and see which Baselines create the Conflicts).
![image](https://github.com/user-attachments/assets/cc457a63-4bef-482d-bf3f-748e97099a18)
In the inspector you can see that there is only one repository target and one load configuration.

You can click on the copy button on the top of the `BaselineLocker` window to copy in the clipboard the current dependencies configuration.
You can paste the configuration in the baseline class. 
For example for Pyramid:
```st
spec baseline: 'Alexandrie' with: [
	spec repository: 'github://pharo-graphics/Alexandrie:master/src'. "BaselineOfBloc"
].

spec baseline: 'BitmapCharacterSet' with: [
	spec loads: #('Core'). "BaselineOfXMLParser"
	spec repository: 'github://pharo-contributions/BitmapCharacterSet:v1.2.x/src'. "BaselineOfXMLParser"
].

spec baseline: 'Ston' with: [
	spec repository: 'github://svenvc/ston/repository'. "BaselineOfBlocSerialization"
].

spec baseline: 'OrderPreservingDictionary' with: [
	spec loads: #('Core'). "BaselineOfXMLParser BaselineOfXMLWriter"
	spec repository: 'github://pharo-contributions/OrderPreservingDictionary:v1.6.x/src'. "BaselineOfXMLParser BaselineOfXMLWriter"
].

spec baseline: 'StashSerialization' with: [
	spec repository: 'github://Nyan11/Stash/src'. "BaselineOfBlocSerialization"
].

spec baseline: 'XMLWriter' with: [
	spec loads: #('Core'). "BaselineOfXMLParser"
	spec repository: 'github://pharo-contributions/XML-XMLWriter:v3.1.x/src'. "BaselineOfXMLParser"
].

spec baseline: 'XMLParser' with: [
	spec loads: #(#Core). "BaselineOfBloc"
	spec repository: 'github://pharo-contributions/XML-XMLParser:master/src'. "BaselineOfBloc"
].

spec baseline: 'Bloc' with: [
	spec repository: 'github://pharo-graphics/Bloc:master/src'. "BaselineOfBlocSerialization BaselineOfToplo BaselineOfAlbum"
].

spec baseline: 'BlocSerialization' with: [
	spec repository: 'github://OpenSmock/Bloc-Serialization:main/src'. "BaselineOfPyramid BaselineOfToploSerialization"
].

spec baseline: 'Album' with: [
	spec repository: 'github://pharo-graphics/Album:master/src'. "BaselineOfToplo"
].

spec baseline: 'Toplo' with: [
	spec repository: 'github://OpenSmock/Toplo:dev/src'. "BaselineOfToploSerialization"
].

spec baseline: 'ToploSerialization' with: [
	spec repository: 'github://OpenSmock/Toplo-Serialization:main/src'. "BaselineOfPyramid"
].

self flag: #MANUALLY. "No config found. Either do mannually or remove"
spec baseline: 'Pyramid' with: [
].


```

There are 2 type of operation you need to do after pasting the configuration:
- `self flag: #MANUALLY`: The config is empty, either remove this part or write it by hand.
- `self flag: #CHOOSE.`: When a conflic between multiple version of a baseline appears you need to choose wich one to select.

