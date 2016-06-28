


# Stata requirements
Several components of this analysis require matsize to be set above 800 (for example in calculation of teacher value-added scores), which generally requires StataMP.


# Required stata packages:
   - `lookfor` (findit lookfor)


# Adding .ado files
In addition to packages one can install, this codes also make use of two included
ado files, both located in the `ado` folder. To install these, you must place
them in your system's ado directory.

To find the ado directory, type `sysdir` in Stata, locate the "personal" folder
(any will work, but that's where it *should* probably go), place the two ado
files in the included ado folder (interact.ado and interact_scores.ado) in
that directory, and restart Stata.

Note `sysdir` will list the places Stata looks for ado files, even if those folders
don't exist. For example, I didn't actually have a directory called "personal"
where Stata was looking for it, so I had to create one first.
