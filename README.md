# BaselineLocker

Check dependencies of a Baseline.
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

![image](https://github.com/user-attachments/assets/97c8f7e6-f135-46f1-8927-62edb3961062)

In the input field on top you can enter multiple Baselines.
For example: `BaselineOfPyramid . BaselineOfSton . BaselineOfToplo`.

In the table:
- **#**: Is the number of baselines that reference this project.
- **loads**: Is the load project for this baseline. If empty then it is the default load, if 'Conflict' multiple config possible.
- **name**: Is the name of the baseline.
- **repositories**: Is the targeted repository inside the baselines and sub-baselines ('Conflict' when multiple baseline want to change the repository.
- **License**: The license found inside the local Iceberg repository. It was choosen to not fetch the license online, using the github REST API for example, because it taken too much time. **Be carefull** the license may not be up to date. 

### Inspect a baseline

You can right-clic on the table to browse a specific baseline or inspect the model (and see which Baselines create the Conflicts).
![image](https://github.com/user-attachments/assets/f84ec093-99e7-42a0-a825-a4e73852e113)

You can browse the baseline from the menu.

![image](https://github.com/user-attachments/assets/2289e864-2c72-43b2-95c0-440bfed543a9)
In the inspector, you can see that the Bloc baseline is referenced in 3 other baselines.
They all target the same version (or branch) therefor there is no conflicts between them.

You can also have the full text version of the licence.
**Be carefull it is the version of the License as loaded in your Iceberg repository.
It may not be up-to-date.**
Because it use the local repository, there is only one version of the license even in case of conflics.

### Quick baseline creation

You can click on the copy button on the top of the `BaselineLocker` window to copy in the clipboard the current dependencies configuration.
You can paste the configuration in the baseline class.

There are 2 type of operation you need to do after pasting the configuration:
- `self flag: #MANUALLY`: The config is empty, either remove this part or write it by hand.
- `self flag: #CHOOSE.`: When a conflic between multiple version of a baseline appears you need to choose wich one to select.

For example for Pyramid:
```st
spec baseline: 'Alexandrie' with: [
	spec repository: 'github://pharo-graphics/Alexandrie:master/src'. "MIT License -> (BaselineOfBloc)"
].

spec baseline: 'BitmapCharacterSet' with: [
	spec loads: #('Core'). "BaselineOfXMLParser"
	spec repository: 'github://pharo-contributions/BitmapCharacterSet:v1.2.x/src'. "MIT License -> (BaselineOfXMLParser)"
].

spec baseline: 'Ston' with: [
	spec repository: 'github://svenvc/ston/repository'. "MIT License -> (BaselineOfBlocSerialization)"
].

spec baseline: 'OrderPreservingDictionary' with: [
	spec loads: #('Core'). "BaselineOfXMLParser BaselineOfXMLWriter"
	spec repository: 'github://pharo-contributions/OrderPreservingDictionary:v1.6.x/src'. "MIT License -> (BaselineOfXMLParser BaselineOfXMLWriter)"
].

spec baseline: 'StashSerialization' with: [
	spec repository: 'github://Nyan11/Stash/src'. "MIT License -> (BaselineOfBlocSerialization)"
].

spec baseline: 'XMLWriter' with: [
	spec loads: #('Core'). "BaselineOfXMLParser"
	spec repository: 'github://pharo-contributions/XML-XMLWriter:v3.1.x/src'. "MIT License -> (BaselineOfXMLParser)"
].

spec baseline: 'XMLParser' with: [
	spec loads: #(#Core). "BaselineOfBloc"
	spec repository: 'github://pharo-contributions/XML-XMLParser:master/src'. "MIT License -> (BaselineOfBloc)"
].

spec baseline: 'Bloc' with: [
	spec repository: 'github://pharo-graphics/Bloc:master/src'. "MIT License -> (BaselineOfBlocSerialization BaselineOfToplo BaselineOfAlbum)"
].

spec baseline: 'BlocSerialization' with: [
	spec repository: 'github://OpenSmock/Bloc-Serialization:main/src'. "MIT License -> (BaselineOfPyramid BaselineOfToploSerialization)"
].

spec baseline: 'Album' with: [
	spec repository: 'github://pharo-graphics/Album:master/src'. "MIT License -> (BaselineOfToplo)"
].

spec baseline: 'Toplo' with: [
	spec repository: 'github://OpenSmock/Toplo:dev/src'. "MIT License -> (BaselineOfToploSerialization)"
].

spec baseline: 'ToploSerialization' with: [
	spec repository: 'github://OpenSmock/Toplo-Serialization:main/src'. "MIT License -> (BaselineOfPyramid)"
].

self flag: #MANUALLY. "No config found. Either do mannually or remove"
spec baseline: 'Pyramid' with: [
].


```

