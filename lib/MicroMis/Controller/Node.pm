package MicroMis::Controller::Node;
use Mojo::Base 'Mojolicious::Controller';

# 信息列表
# http://127.0.0.1:3000/api/v1/nodes
# GET
sub index {
  my $c = shift;
  
  my $nodes  = $c->db->get_collection( 'nodes' );
  my @result = $nodes->find({ });
  
  $c->render(
    json   => { nodes => \@result },
    status => 200
  );
}

sub store {
  my $c = shift;
  
  return undef;
}

sub show {
  my $c = shift;
  
  return undef;
}

sub update {
  my $c = shift;
  
  return undef;
}

sub destroy {
  my $c = shift;
  
  return undef;
}

1;