TYGOLView
=========

An iOS UIView subclass that runs Conway's Game Of Life.

You can use this 
 - To replace a boring spinner as a loading indicator.
 - As the header view of a UITableView
 - As a placeholder on a screen that doesn't have any data.

Usage:
------

Please use the custom initializer provided to init the view. It supports a couple of interesting Game of life patterns 
out of the box, but if you'd like to, you can always tweak the code to add more in the `seedPattern:` method.

The colors of dead / live cells can also be changed via code. Modify the colors `initWithFrame` method to suit your
needs.
