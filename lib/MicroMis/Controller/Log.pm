package MicroMis::Controller::Log;
use Mojo::Base 'Mojolicious::Controller';

# 日志列表
# http://127.0.0.1:3000/api/v1/logs
# GET
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