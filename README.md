*File description*
Written by Christine Mahajan 4/6/2026
VSmolStitch is a Mathematica notebook designed to do 2 things:
(1) Calculate the constraints and virtual site weights for virtual site coarse-grained force fields.
(2) Stitch together the different virtual site groups and other residues of a molecule or polymer for gromacs .gro and .itp files. 
It will calculate bonded potentials, exclusions and pairs as monomers are added.

It requires a .m file that contains the functions needed for the notebook to work correctly: format.m.
Store format.m in the same directory as vsMolStitch.nb

The notebook is divided into the following sections:
Input files and parameters
Global variables declaration
Essential Functions
Custom potentials
Calculations for virtual sites for .itp files
Molecule stitch set up
Outputs for molecule stitch



*Required files and formatting*

To run the notebook, you need two files. A .pdb and a .itp file.
Import the monomer .itp and .pdb into Mathematica as a 'Table' with the built-in Import function in Mathematica.

The .pdb file format follows HETATM format and the coordinates should be formatted:
"HETATM" serial# atomname residuename residue#(always 1) Xcoord Ycoord Zcoord element
To calculate potentials you also need the chemical bond matrix lines (CONECT)

The .itp input file follows a certain order and is designed to skip lines leading with ';' . 
The headings below are required in the .itp file. The atoms section must have atom definitions, but the other sections do not require definitions.
You can copy the headings for your .itp file below:

[ atoms ]
;    serial number; atom type; residue number; residue name; atom name; charge group number; q(e); m(u)

[ constraints ]
; real1 real2 funct(1,bonded/2,nonbonded)    dist

[ virtualsites3 ]
;  vs real1 real2 real3  funct   a         b
; ai  aj funct

[ bonds ]
; ai  aj  ak funct

[ angles ]
; ai  aj  ak funct

[ dihedrals ]
; ai  aj  ak  al funct

The comment lines indicate the format needed to fill out the .itp file according to the gromacs reference manual.
When the output file is written,
the default functions used are 1 for bond and angle, 
3 for proper dihedrals and 2 for improper dihedrals.



*Getting constraints and virtual sites*

If you don't know the virtual sites and constraints, you can run the calculations for the weights on the fly for virtual sites .itp files section.
We use virtual sites3 to define virtual sites on a plane.
Virtual sites on stiff moieties need 3 real atoms that are constrained to make a plane.
Copy and paste the weights to your .itp file before running the stitch setup.

Calculate the distance between real atoms for constraints with:
computeDist[monomerPDB, real1, real2]

Calculate virtual site basis set weights with:
computeVSConstraint[monomerPDB, vs atom#, real1, real2, real3]



*stitching monomer functions*

Monomers are stitched together with 'addFirstMonomer' and 'addNextMonomer' functions.
Calling these functions extracts the coordinates and monomer info and appends them to global variable lists for output.
You will want to keep track of the monomers by the order you add them, which will become their residue number.

The first monomer is straightforward. Only the .pdb and .itp files previously imported are needed. Call them into the function as a list:
addFirstMonomer[ {monPDB, monITP} ]

'addNextMonomer' transforms the coordinates of a new monomer by rotating and translating the new monomer with respect to the coordinates from the existing monomers already added.
New bonds, angles and dihedrals are calculated between the two monomers.
To add new monomers, we need additional parameters specified to know where the new monomer will sit relative to monomers placed before it.
To add the next monomer to a chain, call:
addNextMonomer[{newpdb,newitp},{an,bn,cn},oldres,{ao,bo,co}, lbond, phi:(default 180)]

where
{newPDB,newITP} is the list of the monomer .pdb and .itp files to be stitched on to the existing polymer.
'oldres' is the residue number of the old monomer we want to connect to.
{an,bn,cn} is a list of three atom indices on the new monomer we want to connect.
Likewise, {ao,bo,co} is a list of the three atom indices on the monomer specified by 'oldres'.

The atom indices here refers to the serial# of the input .pdb files for old and new monomers (not the indices of the stitched polymer).
an is directly connected to ao.
'bn' is an atom connected to 'an' and likewise for the old atom indices.
This atom defines the angles, proper dihedrals and will be used in calculating the dihedral angle between old and new moieties when transforming the coordinates.
'cn' is another atom specified for improper dihedrals.
'lbond' is the bond length between 'an' and 'ao', taken from a reference or calculated with DFT.
'phi' is the dihedral angle between 'bo' and 'bn' when stitching the molecule together. The default value is 180 but can be changed.

A 3d structure visualization is added to make sure the monomers are added correctly. 
The new monomer coordinates are transformed based on the existing polymer chain coordinates for the residue and the indices specified.
Because the transformation of the new monomer atoms depends on the atom indices, the stitched molecule geometry will differ from energy minimized polymer. 
See computeDummy in the functions if you want to know more about how the transformation is performed.
For your convenience, an input parameters section is provided to specify atom indices, 
where you can name the atom index groups to keep track of them in complicated molecules.
You can see how I use this section in the notebook provided.



*special functions*
Extra potentials between monomers that are already placed can be added with 'addToPotential'.
addToPotential[n1, {a1, b1, c1}, n2, {a2, b2, c2}]

'n1' and 'n2' are the residues we want to connect, and a, b and c are the atom indices previously described.
The function calculates bond, angles, dihedrals, and improper dihedrals, as well as the chemical bonds that are used for generating pairs and exclusions.

Some molecules will have monomers that will need different types of potentials added. 
These can be added in the custom potentials section.

I have added custom functions used to make the stiff backbone of Y6.
These use the same inputs as 'addToPotential' and 'addNextMonomer',
but they differ in the dihedrals that are added.
First, stiff monomers in the fused ring core are added with just 1 dihedral.
addStiffMon[{newpdb,newitp},{an,bn,cn},oldres,{ao,bo,co}, lbond, phi]

Then additional bonds, angles and dihedrals were added with the second fused bond between BTD and TTP.
addSpecialBond[n1, {a1, b1, c1}, n2, {a2, b2, c2}]

Next the end groups were added, which were stiff enough to use harmonic potentials in place of any proper dihedrals.
'addNextMonomerH[{newpdb,newitp},{an,bn,cn},oldres,{ao,bo,co}, lbond, phi]'

You can rotate a molecule after placing monomers to a new direction with rotateMol
rotateMol[atom1, atom0, vector, r0 : -1]

atom1 and atom0 create a vector along the polymer. 
The vector is the direction we wish to align to, 
r0 is a reference atom when writing out the new coordinates.



*outputs*
After stitching the pairs and exclusions are generated, the .gro and .itp files are written.
The .itp file is written using writeITPLines['molecule'], and writeGroLines['molecule'] writes the .gro file.
Here, 'molecule' is a string that represents the name of the molecule you have stitched together.



*other things*
In vsMolStitch, the cells that must be changed by the user are highlighted in blue and custom cells are highlighted in cyan.

You will need to supply a parameter file that contains the atom/particle type definitions, the non-bonded and bonded parameters.

Virtual sites are a massless particle type, to conserve mass in virtual site groups, the mass must be distributed among the real atoms.
You can see in the example monomer .itp files how this is done.

I have supplied .itp files, .pdb files for monomers, as well as a parameter.itp file as an example taken from:
Mahajan, C. L.; Gomez, E. D.; Milner, S. T. Resolving the Atomistic Morphology of Domains and Interfaces in PM6:Y6 with Molecular Dynamics. 
Macromolecules 2025, 58 (5), 2765-2778. https://doi.org/10.1021/acs.macromol.4c02588.
