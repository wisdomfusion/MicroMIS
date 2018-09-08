package MicroMis::Controller::Tag;

use Mojo::Base 'Mojolicious::Controller';

my $tag_model = MicroMis::Model::Tag->new;

# 标签列表
# http://127.0.0.1:3000/api/v1/tags
# GET
sub index {
  my $c = shift;
  my $params = $c->req->params->to_hash;
  
  my $cursor = $tag_model->find;
  my $total  = $tag_model->count;
  my $res    = $tag_model->paginate( $cursor, $total, $params );
  
  $c->success( $res );
}

1;