package MicroMis::Model::Base;

use strict;
use warnings;

use Mojo::Base -base;
use Storable qw( dclone );

# find documents
sub find {
  my $class   = shift;
  my $filter  = shift || { };
  my $options = shift || { };
  
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  
  my $hidden_fields = { };
  if ( $class->hidden_fields && length $class->hidden_fields ) {
    $hidden_fields = { map { $_ => 0 } $class->hidden_fields };
  }
  
  $coll->find( $filter, $options )->fields( $hidden_fields );
}

# find a document
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

# find a document by oid
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

# add a new document
sub add {
  my ( $class, $document ) = @_;
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  $coll->insert_one( $document );
}

# delete documents
sub delete_many {
  my ( $class, $filter ) = @_;
  return undef unless $filter;
  
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  $coll->delete_many( $filter );
}

# delete a document
sub delete_one {
  my ( $class, $filter ) = @_;
  return undef unless $filter;
  
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  $coll->delete_one( $filter );
}

# update a document
sub update {
  my ( $class, $filter, $update ) = @_;
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  $coll->update_one( $filter, $update );
}

# count documents
sub count {
  my ( $class, $filter ) = @_;
  my $coll = MicroMis::Model->db->get_collection( $class->collection );
  $coll->count_documents( $filter );
}

# get a lazy cursor of a collection
sub cursor {
  my $class = shift;
  MicroMis::Model->db->get_collection( $class->collection );
}

# data pagination
sub paginate {
  my $class  = shift;
  my $cursor = shift;        # mongo lazy cursor
  my $total  = shift;
  my $params = shift || { }; # params includes 'page' or 'per_page'
  
  my $per_page = $params->{ per_page } || MicroMis::Model->per_page;
  my $page     = $params->{ page }     || 1;

  my $skip_num = $page > 1 ? 1 * ( $page - 1 ) * $per_page : 0;
  my @data     = $cursor->limit( $per_page )->skip( $skip_num )->all;
  
  +{
    data     => \@data,
    total    => $total,
    per_page => $per_page,
    page     => $page
  };
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