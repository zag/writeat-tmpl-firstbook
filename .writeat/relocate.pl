#!/usr/bin/env perl
#==========================================================================
#
#         FILE: update_rss.pl
#
#  DESCRIPTION:  Relocate rss mp3 entities
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#==========================================================================

#0 *  * * * ( wget -O /tmp/pod.xml 'http://pipes.yahoo.com/pipes/pipe.run?_id=ff7971ec00d13e5b66d2a6697e675819&_render=rss' && $HOME/bin/relocaterss.pl < /tmp/pod.xml > /usr/home/zag/sites/gwh.zag.ru/www/pod.out.xml ) >> /tmp/podcasts.update.log 2>&1

our $LOCAL_DIR;
our $FILE_PREFIX;

our %NEWFILES;
package Relocate;

#use constant LOCAL_DIR => '/usr/home/zag/sites/gwh.zag.ru/www/data';
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
	
#	diag Dumper($attr);
#	diag "GET * ". $attr->{fileref}."\n";
#	diag  "LOCAL:" . $self->{er};
	diag "copy $orig $dst_copy";
	
	
    }
    return $elem;
}

sub on_characters {
    my ( $self, $elem, $str ) = @_;
    utf8::encode( $str) if utf8::is_utf8($str);
#    warn "utf!" if utf8::is_utf8($str);
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
#use open ':encoding(utf8)';
use open ':utf8';

my ( $help, $man, $dir, $prefix, $todir );
my %opt = (
    help         => \$help,
    man          => \$man,
    'dir|d=s'    => \$dir,
    'prefix|p=s' => \$prefix,
    'todir=s'	 =>\$todir
);    #meta=>\$meta,);
GetOptions(%opt)

  #, 'help|?', 'man', 'dir|d=s', 'cid|s=s', 'f', 'url|u=s', 'list|l' )
  or pod2usage(2);
pod2usage(1) if $help;
pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

if ($dir) {
#    pod2usage(
#        -exitstatus => 2,
#        -message    => "Not exists out dir [-d] : $dir"
#    ) unless -e $dir;
}
else {
    pod2usage( -exitstatus => 2, -message => 'Need  out dir [-d] !' );
}

pod2usage( -exitstatus => 2, -message => 'Need  prefix for files [-p] !' )
  unless $prefix;

$LOCAL_DIR   = $dir;
$FILE_PREFIX = $prefix;

#exit;

#my $buf;
#my $w = new XML::SAX::Writer:: { Output => $buf };
my $w = new XML::SAX::Writer:: { Output => \*STDOUT };
my $r = new Relocate:: from=>$dir, to=>$prefix, todir=>$todir;
my $parser = create_pipe( $r, $w );
#undef $/;
$parser->parse(\*STDIN);
#print $buf;
# delete old files

=head1 NAME

  B<update_rss.pl>  - command line tool for update partners RSS

=head1 SYNOPSIS

  update_rss.pl -d ../www/data/mp3 -prefix ../mp3 < remote.xml > ../www/data/rss.xml


   options:

    -help  - print help message
    -man   - print man page
    -d dir  - out dir for mp3 files
    -prefix - prefix for path in xml for files

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits

=item B<-man>

Prints manual page and exits

=item B<-c> L<config filename>

Set L<config filename> config file name

=back

=head1 DESCRIPTION

  B<update_rss.pl>  - command line tool for update partners RSS

=head1 EXAMPLE

   update_rss.pl -c ../etc/krs.ini  


=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zahatski@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

