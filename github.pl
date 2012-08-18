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
Readonly my $LOCAL_GIT_DIR => "$ENV{HOME}/github/pdurbin";
Readonly my $GIT_CMD       => $ARGV[0] || 'pull';
Readonly my $DOTDOT        => q{..};

chdir $LOCAL_GIT_DIR or croak "Couldn't cd to $LOCAL_GIT_DIR";

my $project_list_json = get($PROJECT_INDEX);

if ( !$project_list_json ) {
    croak "Couldn't download project index from $PROJECT_INDEX";
}

my $project_list_dd = from_json($project_list_json);

for my $repo ( @{$project_list_dd} ) {
    my ($project_local) = $repo->{ssh_url} =~ qr{^git[@]github[.]com:pdurbin/(.*)[.]git$}ms;
    if ( chdir $project_local ) {
        printf '%-31s', "$project_local... ";
        system "git $GIT_CMD";
        chdir $DOTDOT;
    }
    else {
        print "Could not cd to $project_local. Clone with:\ngit clone $repo->{ssh_url}\n";
    }
}
