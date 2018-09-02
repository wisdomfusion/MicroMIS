package MicroMis::Controller::Category;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

# 分类列表
# http://127.0.0.1:3000/api/v1/cates
# GET
sub index {
  my $c = shift;
  
  my $categories = $c->db->get_collection( 'categories' );
  my @result = $categories->find({ });
  
  $c->render(
    json   => { categories => \@result },
    status => 200
  );
}

sub store {
  my $c = shift;
  
  return undef;
}

sub destroy {
  my $c = shift;
  
  return undef;
}

1;