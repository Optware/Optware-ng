#!/usr/bin/env perl
#
# for usage information, run "perl optware-check-package.pl --help"
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
use Getopt::Long qw(:config pass_through);

$verbose=0;
$need_help=0;
$thorough=0;
$file_binary="file";
$objdump_binary="objdump";
$grep_binary="grep";
$num_errors=0;
$num_packages_checked=0;
$stop_on_error=0;
$tmp_dir="/tmp/optware-check-package";
$base_dir="/home/slug/optware/packages";
$binary_type="ARM";

GetOptions("tmp-dir=s" => \$tmp_dir,
	   "base-dir=s" => \$base_dir,
	   "file-path=s" => \$file_binary,
	   "objdump-path=s" => \$objdump_binary,
	   "grep-path=s" => \$grep_binary,
	   "target=s" => \$binary_type,
	   "stop-on-error" => \$stop_on_error,
	   "thorough" => \$thorough,
	   "h" => \$need_help,
	   "--help" => \$need_help,
	   "v" => \$verbose,
	   "verbose" => \$verbose);

%target_to_bintype = (
#       OPTWARE_TARGET => `file binary`
        "nslu2" => "MSB .* ARM",
        "slugosbe" => "MSB .* ARM",
        "fsg3" => "MSB .* ARM",
        "wl500g" => "MIPS",
        "ds101" => "MSB .* ARM",
        "ds101g" => "PowerPC or cisco 4500",
        "gumstix1151" => "LSB .* ARM",
        "nas100d" => "MSB .* ARM",
        "mss" => "MIPS",
        "ddwrt" => "MIPS",
        "oleg" => "MIPS",
        "brcm24" => "MIPS",
        "ts101" => "PowerPC or cisco 4500",
        "ts72xx" => "LSB .* ARM"
);

if (exists $target_to_bintype{$binary_type}) {
	$binary_type = $target_to_bintype{$binary_type};
}
else {
	$binary_type="ARM" if $binary_type =~ /^arm/;
	$binary_type="MIPS" if $binary_type =~ /^mips/;
}

$need_help=1 if $#ARGV<0;

### a wrapper for system()
sub invoke
{
    my $cmd=shift ||die;
    my $dir=shift;
    my $cwd=getcwd();

    chdir $dir if defined($dir);
    if($verbose) {
	print "(in $dir) " if defined($dir);
	print "$cmd\n";
    }
    system($cmd);
    chdir $cwd if defined($dir);

    die $! if($?==-1);
    die "Interrupted." if($?&127);

    return $?==0;
}

sub invoke_quiet
{
    my $cmd=shift ||die;
    my $dir=shift;
    my $cwd=getcwd();

    chdir $dir if defined($dir);
    system($cmd);
    chdir $cwd if defined($dir);

    die $! if($?==-1);
    die "Interrupted." if($?&127);

    return $?==0;
}

sub error {
    my $f=shift ||die;
    my $problem=shift ||die;

    $num_errors++;

    # beautify $f
    $f =~ s%^$tmp_dir/%%;

    print "$f: $problem\n";
    exit 2 if $stop_on_error;
}

sub extract_rpath {
    my $objdump_output=shift ||die;

    $objdump_output =~ /^\s*RPATH\s+(.*)/m
	||return undef;

    return $1;
}

sub extract_needed {
    my $objdump_output=shift ||die;
    my @needed;

    while($objdump_output =~ /^\s*NEEDED\s+(.*)/mgc)
    { push @needed,$1; }

    return @needed;
}

sub check_elf {
    my $f= shift ||die;

    my $objdump_sez=`$objdump_binary -p $f`;
    my $rpath=extract_rpath($objdump_sez);
    my @needed=extract_needed($objdump_sez);
    my $has_strange_libs=0;

    # Check for some libaries known to be found in /lib
    foreach my $l (@needed) {
	next if($l =~ /^lib[mc]\.so\..$/);
	next if($l =~ /^libcrypt\.so\..$/);
	next if($l =~ /^libdl\.so\..$/);
	next if($l =~ /^libnsl\.so\..$/);
	next if($l =~ /^libgcc_s\.so\..$/);
	next if($l =~ /^libpthread\.so\..$/);
	$has_strange_libs=1;
    }

    if(!$has_strange_libs) {
	# no rpath needed in this case
    }
    elsif(!$rpath) {
	error($f,"has no rpath (@needed)");
    }
    else {
	#print "$f: rpath='$rpath'\n" if $verbose;
	
	my @rpath=split /:/,$rpath;
	my $found_opt_lib=0;
	foreach my $rp (@rpath) {
	    $found_opt_lib=1 
		if $rp eq '/opt/lib';
	    error($f,"has a suspicious rpath element '$rp'") 
		unless $rp =~ m%^/opt%;
	}
	error($f,"lacks /opt/lib in rpath") unless $found_opt_lib;
    }
}

sub check_binary {
    my $f = shift ||die;
    -r $f ||die;

    my $file_sez=`$file_binary $f`;

    if($file_sez =~ /ELF [^,]* (executable|shared object)/) {
	print "  ELF binary: $f\n" if $verbose; 

	error($f,"is not stripped") if($file_sez =~ /not stripped/);
	error($f,"is statically linked") if($file_sez =~ /statically linked/);
	error($f,"is not an $binary_type binary") if($file_sez !~ / $binary_type,/);

	check_elf($f);
    }
    
}

sub check_static_lib {
    my $f = shift ||die;
    -r $f ||die;

    error($f,"is a redundant static lib") if($f =~ /(.*).a$/ && -r "$1.so");
}

sub check_compile_time_paths {
    my $f = shift ||die;
    -r $f ||die;

    if(invoke_quiet("$grep_binary -qF $base_dir $f")) {
	error($f,"contains host paths");
    }
}

sub check_file {
    my $f = shift ||die;
    -r $f ||die "$f not readable";
    
    check_compile_time_paths($f);
    check_static_lib($f) if($f =~ /\.a$/);
    check_binary($f) if(-x $f || $f=~/\.so/ || $thorough);
}

sub check_subdir {
    my $dir=shift ||die;
    -d $dir ||die;
    print "Checking in directory $dir...\n" if $verbose;

    foreach my $f (glob "$dir/*") {
	if($f =~ /^[.]/) { next; }
	elsif(-l $f) { next; }
	elsif(-d $f) { check_subdir($f); }
	else { check_file($f); }
    }
}

sub check_dir {
    my $dir=shift ||die;
    -d $dir ||die;
    print "Checking in root $dir...\n" if $verbose;

    foreach my $f (glob "$dir/*") {
	if($f =~ /^[.]/) { next; }
	elsif(-d $f && $f =~ m%/CONTROL$%) { check_subdir($f); }
	elsif(-d $f && $f =~ m%/opt$%) { check_subdir($f); }
	else { error($f, "is installed outside /opt"); }
    }
}

sub check_ipk {
    my $f=shift ||die;
    -r $f ||die "$f is not readable";

    $f =~ m%(.*/)?(.*?)\.ipk% ||die "weird package name '$f'";
    my $name=$2;
    #print "name='$name'\n" if $verbose;

    my $dir="$tmp_dir/$name";

    mkdir $tmp_dir;
    mkdir $dir;
    invoke "tar -xOzf $f ./data.tar.gz |tar -C $dir -xzf -";
    check_dir $dir;
    invoke "rm -rf $dir\n";

    $num_packages_checked++;
}

if($need_help)
{
    print <<EOF;
Usage: perl -w optware-check-package.pl [options] [packages] [directories]

For each ipk package listed on the commandline, scans that package for
common packaging problems (for example broken RPATHs, static binaries,
host paths).  Directories are treated as unpacked packages.

Options:
  --tmp-dir=<dir>	Use <dir> as a temporary area for unpackaging.
  --file-path=<f>	Use <f> as the location of the "file" utility.
  --objdump-path=<f>	Use <f> as the location of the "objdump" utility.
  --target=<t>		Set the optware target: nslu2 or wl500g.
  --stop-on-error	Stop immediately if there is an error.
  --thorough		Check files more aggressively, but more slowly.
  --help		Display this message.
  --verbose		Emit more output while checking.
EOF
    exit 0;
}

foreach my $i (@ARGV) 
{
    if(-d $i)
    { check_dir($i);}
    elsif($i =~ /\.ipk$/)
    { check_ipk($i);}
    else
    {
	print "I don't know what to do with '$i'\n";
	exit 2;
    }
}

if($num_errors)
{
    print "There were $num_errors errors\n";
    exit 2;
}
if($num_packages_checked)
{
    print "$num_packages_checked package(s) were checked.\n";
}
