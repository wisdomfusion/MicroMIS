package MicroMis::Model::Base;

use strict;
use warnings;

use Mojo::Base -base;

# MongoDB:
#   $cursor = $coll->find( $filter );
#   $cursor = $coll->find( $filter, $options );
#   $cursor = $coll->find({ i => { '$gt' => 42 } }, {limit => 20});
sub all {
  my $class   = shift;
  my $filter  = shift || { };
  my $options = shift || { };
  
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  
  my $hidden_fields = { };
  if ( $class->hidden_fields && length $class->hidden_fields ) {
    $hidden_fields = { map { $_ => 0 } $class->hidden_fields };
  }
  
  $coll->find( $filter, $options )->fields( $hidden_fields )->all;
}

# MongoDB:
#   $doc = $collection->find_one( $filter, $projection );
#   $doc = $collection->find_one( $filter, $projection, $options );
sub find_one {
  my $class  = shift;
  my $filter = shift || { };
  
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  
  my $hidden_fields = { };
  if ( $class->hidden_fields && length $class->hidden_fields ) {
    $hidden_fields = { map { $_ => 0 } $class->hidden_fields };
  }
  
  $coll->find_one( $filter, $hidden_fields );
}

# MongoDB:
#   $doc = $collection->find_id( $id );
#   $doc = $collection->find_id( $id, $projection );
#   $doc = $collection->find_id( $id, $projection, $options );
sub find_id {
  my ( $class, $oid ) = @_;
  return undef unless $oid;
  
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  
  my $hidden_fields = { };
  if ( $class->hidden_fields && length $class->hidden_fields ) {
    $hidden_fields = { map { $_ => 0 } $class->hidden_fields };
  }
  
  $coll->find_id( $oid, $hidden_fields );
}

# MongoDB:
#   $res = $coll->insert_one( $document );
#   $res = $coll->insert_one( $document, $options );
#   $id  = $res->inserted_id;
sub add {
  my ( $class, $document ) = @_;
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  $coll->insert_one( $document );
}

# MongoDB:
#   $res = $coll->delete_many( $filter );
#   $res = $coll->delete_many( { name => "Larry" } );
#   $res = $coll->delete_many( $filter, { collation => { locale => "en_US" } } );
sub delete_many {
  my ( $class, $filter ) = @_;
  return undef unless $filter;
  
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  $coll->delete_many( $filter );
}

# MongoDB:
#   $res = $coll->delete_one( $filter );
#   $res = $coll->delete_one( { _id => $id } );
#   $res = $coll->delete_one( $filter, { collation => { locale => "en_US" } } );
sub delete_one {
  my ( $class, $filter ) = @_;
  return undef unless $filter;
  
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  $coll->delete_one( $filter );
}

# MongoDB:
#   $res = $coll->update_one( $filter, $update );
#   $res = $coll->update_one( $filter, $update, { upsert => 1 } );
sub update {
  my ( $class, $filter, $update ) = @_;
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  $coll->update_one( $filter, $update );
}

# MongoDB:
#   $count = $coll->count_documents( $filter );
#   $count = $coll->count_documents( $filter, $options );
sub count {
  my ( $class, $criteria ) = @_;
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  $coll->count_documents( $criteria );
}

# get a collection
sub coll {
  my $class = shift;
  MicroMis::Model->db->get_collection( $class->collection );
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

MicroMis::Model::Base - The base class of models

=head1 SYNOPSIS

  my $user_model = MicroMis::Model::User->new;
  
  @users = $user_model->all;

=cut