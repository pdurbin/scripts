#!/usr/bin/env perl
use strict;
use warnings;
use 5.010000;
use Readonly;
use Carp;
use LWP::Simple qw{get};
use YAML;
#use Data::Dumper;

Readonly my $GIT_SERVER     => 'git.greptilian.com';
Readonly my $GIT_USER       => 'pdurbin';
Readonly my $PROJECT_INDEX  => "http://$GIT_SERVER/?a=project_index";
Readonly my $PROJECT_DIR    => '/var/lib/git';
Readonly my $LOCAL_GIT_DIR  => "$ENV{HOME}/gr";
Readonly my $GIT_CLONE_PATH => "$GIT_SERVER:$PROJECT_DIR";
Readonly my $DOTDOT         => q{..};
Readonly my $FILES_NON_DOT  => q{*};
Readonly my $DESCRIPTIONS   => "http://$GIT_SERVER/?p=wiki.git;a=blob_plain;f=greptilian.com/git/repos.mdwn;hb=HEAD";

chdir($LOCAL_GIT_DIR) or croak "Couldn't cd to $LOCAL_GIT_DIR";

my $project_list = get($PROJECT_INDEX);

if ( !$project_list ) {
    croak "Couldn't download project index from $PROJECT_INDEX";
}

my @projects = split( /\n/, $project_list );
s{^\s+|\s+$}{}g for @projects;

my $descriptions_yaml = get($DESCRIPTIONS);

if ( !$descriptions_yaml ) {
    croak "Couldn't download git repo descriptions_yaml from $DESCRIPTIONS";
}

my $proj_descriptions = Load($descriptions_yaml);

for my $repo ( sort keys %{$proj_descriptions} ) {
    carp "No description for $repo at $DESCRIPTIONS" unless ($repo ~~ @projects);
}

for my $project_bare (sort @projects) {
    carp "No description for $project_bare at $DESCRIPTIONS" unless ${$proj_descriptions}{$project_bare};
    my ($project_local) = $project_bare =~ /^(.*?)[.]git/;
    if ( chdir($project_local) ) {
        printf( '%-30s', "$project_local... " );
        system('git pull');
        chdir($DOTDOT);
    }
    else {
        print
"Could not cd to $project_local. Clone with:\ngit clone $GIT_USER\@$GIT_CLONE_PATH/$project_bare\n";
    }
}
