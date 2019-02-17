#!/usr/bin/env perl
$latex            = 'platex -synctex=1 -halt-on-error';
$bibtex           = 'pbibtex';
$biber            = 'biber  -u -U --output_safechars';
$dvipdf           = 'dvipdfmx %O -o %D %S';
$makeindex        = 'mendex %O -o %D %S';
$max_repeat       = 5;
$pdf_mode         = 3;

