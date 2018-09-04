package MicroMis::Model;

use strict;
use warnings;

use MongoDB;
use Carp qw( croak );

use MicroMis::Model::User;
use MicroMis::Model::Project;
use MicroMis::Model::Category;
use MicroMis::Model::Tag;
use MicroMis::Model::Node;
use MicroMis::Model::Log;

my $DB;

sub init {
  my ( $class, $config ) = @_;
  
  croak 'invalid db config'
    unless $config && $config->{ host } && $config->{ port } && $config->{ db };
  
  unless ( $DB ) {
    my $client = MongoDB::MongoClient->new(
      host => "mongodb://$config->{host}:$config->{port}",
    );
    $DB = $client->get_database( $config->{ db } );
  }
  
  $DB;
}

sub db {
  return $DB if $DB;
  croak 'Init model first!';
}

1;