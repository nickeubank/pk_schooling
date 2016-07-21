
Replication Package for *Decomposing the Government-Private School Performance Differential: Village Ethnic Politics and School Sorting*
==========================================================================================================================================

This repository contains all code necessary for replicating *Decomposing the Government-Private School Performance Differential: Village Ethnic Politics and School Sorting* by Nick Eubank. 


Data
-----------

The data required for replication comes from the Learning and Educational Achievement in Punjab Schools (LEAPS) survey, 
and should be publicly available `from the LEAPS website <http://www.leapsproject.org>`_. If data cannot be 
found there, it should be possible to obtain it from the LEAPS project leads Jishnu Das and Tahir Andrabi. 

Note that as of July 2016, efforts are underway to update the LEAPS data, and the website is currently down. This should be resolved soon. 

Replicating
------------

* Download this repository
* Download the public LEAPS data and place it in the `public_leaps_data` folder in this directory. The data should consist of three folders - `household`, `panels`, and `school` -- along with a standalone `public_mauza.dta` file. 
* Open the `dofiles/master_dofile.do` file and set the global `pk` at the top of the file to the location of this repository. 
* Ensure the lines that call the first set of dofiles in `master_dofile.do` (those in `00_pre_public`) are commented out, along with the assignment of `global datadir`. As noted in the comments, these are included for transparency but require non-public data to run.
* Copy the `interact.ado` file in `dofiles/ado` into your personal ado directory (see notes below for details). 
* Run `findit renvars` in your Stata terminal and install the linked package.
* Run `master_dofile.do`. 

All results should be found in `docs/results`.


Stata requirements
-------------------
All code was designed to run in Stata 12. Note several components of this analysis require matsize to be set above 800 (for example in calculation of teacher value-added scores), which generally requires StataMP.


Adding .ado files
-------------------
In addition to packages one can install directly, this codes also make use of an included
ado file located in the `ado` folder. To install this, you must place
them in your system's ado directory.

To find the ado directory, type `sysdir` in Stata, locate the "personal" folder
(any will work, but that's where it *should* probably go), place the two ado
files in the included ado folder (interact.ado and interact_scores.ado) in
that directory, and restart Stata.

Note `sysdir` will list the places Stata looks for ado files, even if those folders
don't exist. For example, I didn't actually have a directory called "personal"
where Stata was looking for it, so I had to create one first.


Commit history
---------------

Unfortunately, this repository does not include the entire history of this project. This project was originally written as a 
qualifying paper long before I was familiar with `git` and before I had developed good programming style. 

As such, the commit history in this repository begins when I started the process of cleaning and reorganizing all the (spagetti) 
code I had initially written for the qualifying paper.
