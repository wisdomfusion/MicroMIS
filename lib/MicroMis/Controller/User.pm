package MicroMis::Controller::User;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $c = shift;
  
  my $users  = $c->db->get_collection('users');
  my @result = $users->find({ });
  
  $c->render(
    json   => { users => \@result },
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