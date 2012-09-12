#!/usr/bin/env perl
#==========================================================================
#
#         FILE: relocate.pl
#
#  DESCRIPTION:  Relocate images
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#==========================================================================

package Relocate;

use warnings;
use strict;
use XML::ExtOn;
use base qw/ XML::ExtOn/;
use Test::More;
use Data::Dumper;
use File::Path qw(make_path);
use IO::File;
use Encode qw(encode decode is_utf8);

sub on_start_element {
    my ( $self, $elem ) = @_;
    if ( $elem->local_name eq 'imagedata') {
	my $attr = $elem->attrs_by_name;
	#work/git/t/testbook/inc/../img/Describe_Widgets_pic_13m.jpg
	my $from = $self->{from};
	my $to = $self->{to};
	my $todir = $self->{todir};
	#strip
	my $orig= $attr->{fileref};
	$attr->{fileref}  =~s/^$from/$to/;
	my $dst_copy = $orig;
	$dst_copy  =~s/^$from/$todir/;
        
        #clean ..
        $dst_copy =~ s/\.\.//g; 
        my $ref =  $attr->{fileref};
        $ref =~ s/^$to//;
        $ref =~ s/\.\.//g;
        $attr->{fileref} = $to.$ref;

	my ($file, @path) = reverse split (/\//,$dst_copy);
	make_path(join "/", reverse @path);
	my $fh   = new IO::File:: "< " . $orig;
	local $/;
	$/ = undef;
	my $out = new IO::File:: ">$dst_copy" or die $!;
	$out->print(<$fh>);
	$fh->close;
	$out->close;
	diag "copy $orig $dst_copy";
	
	
    }
    return $elem;
}

sub on_characters {
    my ( $self, $elem, $str ) = @_;
    utf8::encode( $str) if utf8::is_utf8($str);
    $elem->{STR} = $str;
    return $str;
}

1;

#
package main;
use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use Test::More;
use XML::ExtOn qw(create_pipe);
use XML::SAX::Writer;
use open ':utf8';

my ( $help, $man, $dir, $prefix, $todir );
my %opt = (
    help         => \$help,
    man          => \$man,
    'dir|d=s'    => \$dir,
    'prefix|p=s' => \$prefix,
    'todir=s'	 =>\$todir
);
GetOptions(%opt)
  or pod2usage(2);
pod2usage(1) if $help;
pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

unless ($dir) {
    pod2usage( -exitstatus => 2, -message => 'Need  out dir [-d] !' );
}

pod2usage( -exitstatus => 2, -message => 'Need  prefix for files [-p] !' )
  unless $prefix;

my $w = new XML::SAX::Writer:: { Output => \*STDOUT };
my $r = new Relocate:: from=>$dir, to=>$prefix, todir=>$todir;
my $parser = create_pipe( $r, $w );
$parser->parse(\*STDIN);

=head1 NAME

  B<relocate.pl>  - relocate images

=head1 SYNOPSIS

 relocate.pl -d SRC_DIR  -p ../img/ -todir DST_DIR


   options:

    -help  - print help message
    -man   - print man page
    -d dir  - out dir for img files
    -p - prefix for path in xml for files
    -todir  - dst dir

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits

=item B<-man>

Prints manual page and exits

=back

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zahatski@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2012 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

