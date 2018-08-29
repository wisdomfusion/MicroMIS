package MicroMis::Controller::Client;
use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $self = shift;
    
    $self->render(text => 'index');
}

1;
