package MicroMis::Controller::Project;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $c = shift;
  
  my $projects = $c->db->get_collection('projects');
  my @result   = $projects->find({ });
  
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