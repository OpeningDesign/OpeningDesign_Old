OpeningDesign Rails Application
===============================

Enable architects, builders and engineers to collaborate on projects
and integrate etherpad technology for online collaboration.

# Notes on Merging Projects and Folders

* experiment so far: update type to 'Project' for each node with type='Folder'
* small fixes
* Changed 'sub folder creation' to create instance of Project.

## TODO

* Migration to update 'type' to 'Project' for each folder instance (a  bit hairy...)

        update nodes set type = "Project" where type = "Folder";

* refactor specs ('migrate' folder specs to be included in project specs, for controller and view and model specs!)
* Change all occurences of 'Folder' to refer to I18n identifiers; maybe same for 'Project', 'project' and 'projects'


## Installation for development

... to be filled in.

## How to modify CSS

... to be filled in.

## License

Proprietary.
