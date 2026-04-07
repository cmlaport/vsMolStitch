(* ::Package:: *)

BeginPackage["MyPackages`format`"]

eFormat::usage = "eFormat[x,n,d] returns an E-format string representing the number x with n total characters (including the sign, decimal, and E) and d digits to the right of the decimal."
\

fFormat::usage = "fFormat[x,n,d] returns an F-format string representing the number x with n total characters (including the sign and decimal) and d digits to the right of the decimal."
\

iFormat::usage = "iFormat[x,n] returns an I-format string representing the integer x with n total characters (including the sign)."
\

aFormat::usage = "aFormat[s,n] returns an A-format string padded with blanks (flush left if n<0) with |n| total characters."
\

Begin["`Private`"]

(* String in e format, left padded with blanks, d decimal places *)

eFormat[x_,n_,d_]:=Module[{out},
out=ToString[NumberForm[x,{100,d},
NumberFormat->(Row[{#1,"e",If[ToExpression[#3]==Null||ToExpression[#3]>=0,"+","-"],
StringPadLeft[ToString[Abs[If[ToExpression[#3]==Null,0,ToExpression[#3]]]],2,"0"]}]&),
ScientificNotationThreshold->{-1,1},NumberPadding->{"","0"}]];
If[StringLength[out]>n,StringPadLeft["",n,"*"],StringPadLeft[out,n," "]]
];

(* exponent format *)

expFormat[n_]:=NumberForm[n,{2,2},NumberSigns->{"-","+"},
NumberPadding->{"0",""},SignPadding->True]

(* Floating point format *)

fFormat[x_,n_,d_]:=Module[{out},
out=ToString[NumberForm[x,{100,d},
ScientificNotationThreshold->{-Infinity,Infinity},
NumberPadding->{"","0"}]];
If[StringLength[out]>n,StringPadLeft["",n,"*"],StringPadLeft[out,n," "]]
];

(* Integer format *)

iFormat[x_,n_]:=Module[{},
out=ToString[NumberForm[x,{n,0}]];
If[StringLength[out]>n,StringPadLeft["",n,"*"],StringPadLeft[out,n," "]]
];

(* string format *)

aFormat[s_,n_]:=If[n>0,
	If[StringLength[s]<=n,
		StringPadLeft[s,n],StringRepeat["*",n]],
	If[StringLength[s]<=-n,
		StringPadRight[s,-n],StringRepeat["*",-n]]
]
	

End[]

EndPackage[]






