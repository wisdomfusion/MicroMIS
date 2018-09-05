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

# db connection
my $DB;

# page size of pagination
my $PER_PAGE;

# 初始化数据库连接，分页大小
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
  
  $PER_PAGE = $config->{ per_page } || 20;
}

# 数据库连接
sub db {
  return $DB if $DB;
  croak 'Init Models First!';
}

# 数据分页大小
sub per_page {
  $PER_PAGE;
}

1;