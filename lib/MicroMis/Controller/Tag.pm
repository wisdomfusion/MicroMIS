package MicroMis::Controller::Tag;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

# 标签列表
# http://127.0.0.1:3000/api/v1/tags
# GET
sub index {
  my $c = shift;
  
  my $tags   = $c->db->get_collection( 'tags' );
  my @result = $tags->find({ });
  
  $c->render(
    json   => { nodes => \@result },
    status => 200
  );
}

1;