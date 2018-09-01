package MicroMis::Controller::Node;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $c = shift;
  
  my $nodes  = $c->db->get_collection('nodes');
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