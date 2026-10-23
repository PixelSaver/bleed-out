# Automatic spatial navigation mapper for Godot

A tool plugin for automatically mapping out spatial UI navigation pathing for interface elements in Godot, originally created as a part of my bachelor's thesis during spring 2025.

<img width="884" height="523" alt="ui_nav_new" src="https://github.com/user-attachments/assets/d362bd29-21ca-4b20-9e19-8654349d6d5f" />

# Features

- Real-time automatic element-to-element and Group-to-group calculations for UI navigation focus references
- Automated non-intrusive and toggleable visualization for determined pathing and groups using Godot's rendering-server, including customizable parameters like colors, size and textures

## Installation

To access the code and install it within Godot, either clone the repository or download the files and move the unzipped (which ever version of the two you need) ‘Spatial navigation mapper’ folder into the ‘addons’ folder within your choice of a Godot-project. For C#, to make the addon visible and accessible within the project, build or run your game once to compile the code and toggle it on via project > project settings > plugins using the checkbox. For the native GDscript version, you should be able to simply toggle it on once the addon folder is in place.

Once the plugin is active, to add a mapping node, 'add a new child node' and search for 'UI-navigation-mapper' within the node selection menu. You can then add UI control nodes to as many 'Navigation groups' as you want, and the tool will handle the rest based on the current parameters. Elements within a group will only primarily map to each other, groups will interact with other groups.

For further documentation on the parameters and variables of the main navigation mapper node, please refer to 'Navmapper_node_info.txt' in the addon folder

Highly recommended to be paired up with [godot-inspector-lock](https://github.com/ctresb/godot-inspector-lock), as said plugin allows you to more easily select to drag & drop multiple nodes into the mappable element arrays

## License

This project is licensed under an MIT license.

See LICENSE for further detail.


## FAQ

#### Q: Why?

As of Godot 4.7, built-in automatic navigation mapping in the engine has no debug visuals, nor any way to access the data for the chosen navigation targets, as far as I know at least. I had a potential want and a need for both of those for some potential future custom UI work as well as some gripes with bugs that I've encountered with the existing automatic mapping which is otherwise extremely tedious to manually manage and upkeep, hence why I chose to originally develop this tool as a project for my bachelor's thesis in 2025.

During my few years in uni, I was also "The UI-guy" for a few of the game projects I was a part of. Given that, I'm well aware of how annoying and tedious UI can be to work on to begin with, thus wanted to make it a little less so.

#### Q: Will this be updated any further?

Some other minor additions, needed fixes if any Godot updates break something and any fixes to potentially encountered bugs may be added down the line

## 🔗 Links
[Twitter](https://x.com/Mantimestwo)
[Youtube](https://www.youtube.com/channel/UCVOaL_jrj6RhFPgmmfbdmog)


