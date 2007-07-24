
#
# for usage information, run "perl optware-autoclean.pl --help"
#
# Copyright (c) 2005 Josh Parsons <jbparsons@ucdavis.edu>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

use Cwd;
use File::stat;
use Getopt::Long;

$optware_dir=undef;
$dry_run=0;
$verbose=0;
$need_help=0;

@out_of_date_packages=();

%uploaded_version=();
%uploaded_maintainer=();
%package_version=();

@blacklist=();
%blacklist=();

GetOptions("optware-dir=s" => \$optware_dir,
	   "C=s" => \$optware_dir,
	   "b=s" => \@blacklist,
	   "blacklist=s" => \@blacklist,
	   "n" => \$dry_run,
	   "dry-run" => \$dry_run,
	   "h" => \$need_help,
	   "--help" => \$need_help,
	   "v" => \$verbose,
	   "verbose" => \$verbose);

### turn the blacklist into a hash
foreach my $i (@blacklist) 
{
    $blacklist{$i}=1;
}

### find optware packages
if(defined($optware_dir))
{
}
elsif(-r "./Makefile") 
{
    $optware_dir=".";
}
elsif(-r "/home/slug/optware/nslu2/packages/Makefile") 
{
    $optware_dir="/home/slug/optware/nslu2/packages";
}
elsif(-r "/home/slug/optware/wl500g/packages/Makefile") 
{
    $optware_dir="/home/slug/optware/wl500g/packages";
}


### a wrapper for system()
sub invoke
{
    my $cmd=shift ||die;
    my $dir=shift;
    my $cwd=getcwd();

    chdir $dir if defined($dir);
    print "(in $dir) " if defined($dir);
    print "$cmd\n";
    system($cmd);
    chdir $cwd if defined($dir);

    die $! if($?==-1);
    die "Interrupted." if($?&127);

    return $?==0;
}

### slurp a file
sub slurp
{
    my $fn=shift ||die;
    local $/;
    open(SLURP,"<$fn") ||return undef;
    my $slurped=<SLURP>;
    close(SLURP);
    return $slurped;
}

### parse a Packages file
sub parse_Packages
{
    local $_;
    my $fn=shift || "$optware_dir/packages/Packages";

    open(IN,"<$fn") ||die "$! opening $fn";
    while(<IN>) {
	my $doclean=0;
	my $pkg_fn;
	my $v;

	chomp;
	next unless /^Package: (.*)/;
	my $p=$1;
	while(<IN>) {
	    chomp;
	    last if /^$/;
	    $uploaded_version{$p}=$1 if /^Version: (.*)/;
	    $uploaded_maintainer{$p}=$1 if /^Maintainer: (.*)/;
	    $pkg_fn="$optware_dir/builds/$1" if /^Filename: (.*)/;
	}

	my $mk_fn="$optware_dir/make/$p.mk";
	next unless -r $mk_fn;
	my $dot_mk=slurp($mk_fn);
	my $mk_stat=stat($mk_fn);
	my $pkg_stat=stat($pkg_fn);

	if($blacklist{$p}) {}
	elsif($pkg_stat && $pkg_stat->mtime<$mk_stat->mtime) {
		print STDERR "$p package is older than makefile\n" if $verbose;
		$doclean=1;
	}
	elsif(defined($dot_mk)) {

	    # try to figure out what the uppercased version of the
	    # package name is.
	    my $p_pattern="\U$p";
	    my $P="\U$p";
	    $p_pattern=~s/\+/\\\+/g;
	    $p_pattern=~s/_/.?/g;
	    $p_pattern=~s/-/.?/g;
	    $P=$1 if $dot_mk=~/(${p_pattern})_VERSION/m;

	    # try to extract version quickly
	    my $v1="";
	    my $v2="";
	    $v1=$1 if $dot_mk=~/^\s*${p_pattern}_VERSION\s*:?=\s*(\S*)/m;
	    $v2=$1 if $dot_mk=~/^\s*${p_pattern}_IPK_VERSION\s*:?=\s*(\S*)/m;
	    $v="$v1-$v2";
	    
	    # if it seems to have failed, slow check with make query
	    unless($uploaded_version{$p} eq $v) {
		my $ipk=`MAKEFLAGS="" make -C $optware_dir -s query-${P}_IPK`;
		chomp $ipk;
		$v=$1 if $ipk=~/\L${p_pattern}_(.*?)_\w+\.ipk$/i;
	    }

	    $package_version{$p}=$v;
	    
	    unless($uploaded_version{$p} eq $v) {
		print STDERR "$p is out of date. Feed=".$uploaded_version{$p}." .mk=$v\n" if $verbose;
		$doclean=1;
	    }
	}

	if($doclean) {
            my @to_rm = ("builds/${p}");
            my $vglob = '*';
            # rm only necessary .ipk if version string is simple
            if ($v =~ /^[\d\.-]*$/) { $vglob = '[0-9.-]*'; }
            push @to_rm, "builds/${p}_${vglob}.ipk", "builds/${p}-${vglob}.ipk";
            push @to_rm, "packages/${p}_${vglob}.ipk", "packages/${p}-${vglob}.ipk";
            foreach (`grep '"Package: *[a-zA-Z0-9_-]* *" *>>' make/$p.mk`) {
                my $subp = (split)[2]; chop $subp;
                push @to_rm, "builds/${subp}_*.ipk", "packages/${subp}_*.ipk" unless $subp eq $p;
            }
	    invoke("rm -rf " . join(" ", @to_rm), $optware_dir) unless $dry_run;
	    push @out_of_date_packages,$p;
	}
    }
    close(IN);
}

sub help 
{
    print <<EOF;
optware-autoclean.pl - clean updated packages from the optware buildroot

This script reads the Packages file and makefiles from the optware
build system, and cleans packages whose version numbers do not match
the version numbers stored in their makefile.

Usage: perl optware-autoclean.pl [options]

Options include:
  -v / --verbose
  -n / --dry-run (do not clean anything, just say what needs cleaning)
  -C<dir> / --optware-dir=<dir> (set the directory of the optware buildroot)

EOF
}

###
###
###

if($need_help)
{
    help();
    exit(0);
}

unless(-r "$optware_dir/Makefile")
{
    help();
    print "I can't find optware: trying using the -C option.\n";
    exit(2);
};

unless(-r "$optware_dir/packages/Packages")
{
    print "No Packages file found. I presume no cleaning is needed.\n" if $verbose;
    exit(0);
};

parse_Packages;
