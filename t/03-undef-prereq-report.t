
use strict;
use warnings;

use Test::More;

# FILENAME: 03-undef-prereq-report.t
# CREATED: 03/23/15 20:25:56 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Test undef in prereq reports

use CPAN::Testers::Common::Client;

my $rreqs = <<"EOF";
version 0
CPAN 0
ExtUtils::Command 0
ExtUtils::ParseXS 0
File::Spec 0
YAML 0
YAML::Syck 0
EOF

my $prereqs = { runtime => { requires => { split /\s+/sm, $rreqs } } };

{

    my $report;
    my @warns;

    {
        local $SIG{__WARN__} = sub { push @warns, $_[0]; };
        $report =
          CPAN::Testers::Common::Client::_format_prereq_report($prereqs);
    }
    if ( ok( !scalar @warns, "No warnings emitted in real report generation" ) )
    {
        note $report;
    }
    else {
        diag explain \@warns;
        diag $report;
    }
}

{
    no warnings 'redefine';

    # Emulate a broken finder that returns an empty hash due
    # to silently SEGV/LD Sym fail.
    *CPAN::Testers::Common::Client::_version_finder = sub { return {} };
}

{

    my $report;
    my @warns;

    {
        local $SIG{__WARN__} = sub { push @warns, $_[0]; };
        $report =
          CPAN::Testers::Common::Client::_format_prereq_report($prereqs);
    }
    if ( ok( !scalar @warns, "No warnings emitted in bad report generation" ) )
    {
        note $report;
    }
    else {
        diag explain \@warns;
        diag $report;
    }
}

{
    my $report;
    my @warns;
    my $installed = {
        good    => 1,
        another => 2,
        bad     => undef,
        zero    => 0,
    };
    {
        local $SIG{__WARN__} = sub { push @warns, $_[0]; };
        $report =
          CPAN::Testers::Common::Client::_format_toolchain_report($installed);
    }
    if ( ok( !scalar @warns, "No warnings emitted by toolchain report" ) ) {
        note $report;
    }
    else {
        diag explain \@warns;
        diag $report;
    }
}

done_testing;

