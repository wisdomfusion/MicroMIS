package MicroMis::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util 'secure_compare';

sub login {
  my $self = shift;
  
  return $self->render(json => { login => 1 });
}

1;