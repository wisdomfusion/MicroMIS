package MicroMis::Controller::Log;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $c = shift;
  
  my $logs = $c->db->get_collection( 'logs' );
  my @result = $logs->find({ });
  
  $c->render(
    json   => { logs => \@result },
    status => 200
  );
}

1;