package MicroMis::Controller::Log;

use Mojo::Base 'Mojolicious::Controller';

my $log_model = MicroMis::Model::Log->new;

# 日志列表
# http://127.0.0.1:3000/api/v1/logs
# GET
sub index {
  my $c = shift;
  my $params = $c->req->params->to_hash;
  
  my $filter = { };
  
  my $cursor = $log_model->find( $filter );
  my $total  = $log_model->count( $filter );
  my $res    = $log_model->paginate( $cursor, $total, $params );
  
  $c->success( $res );
}

1;