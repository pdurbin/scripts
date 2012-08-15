#!/usr/bin/env perl
use strict;
use warnings;
use 5.010000;
use Readonly;
use Carp;
use LWP::Simple qw{get};
use JSON;
#use Data::Dumper;

Readonly my $PROJECT_INDEX => 'https://api.github.com/users/pdurbin/repos';

my $project_list_json = get($PROJECT_INDEX);

if ( !$project_list_json ) {
    croak "Couldn't download project index from $PROJECT_INDEX";
}

my $project_list_dd = from_json($project_list_json);

for my $repo ( @{$project_list_dd} ) {
    print $repo->{ssh_url}, "\n";
}
