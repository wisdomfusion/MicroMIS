package MicroMis::Controller::Node;

use Mojo::Base 'Mojolicious::Controller';

my $node_model = MicroMis::Model::Node->new;

# 信息列表
# http://127.0.0.1:3000/api/v1/nodes
# GET
sub index {
  my $c = shift;
  my $params = $c->req->params->to_hash;
  
  my $filter = { };
  
  my $cursor = $node_model->find( $filter );
  my $total  = $node_model->count( $filter );
  my $res    = $node_model->paginate( $cursor, $total, $params );
  
  $c->success( $res );
}

# 导入信息节点
# http://127.0.0.1:3000/api/v1/nodes
# POST
sub import {
  my $c = shift;
  
  undef;
}

# 添加信息节点
# http://127.0.0.1:3000/api/v1/node
# POST
sub store {
  my $c = shift;
  
  undef;
}

# 信息节点详情
# http://127.0.0.1:3000/api/v1/node/:id
# GET
sub show {
  my $c = shift;
  
  undef;
}

# 编辑信息节点
# http://127.0.0.1:3000/api/v1/node/:id
# PUT
sub update {
  my $c = shift;
  
  undef;
}

# 删除信息节点
# http://127.0.0.1:3000/api/v1/node/:id
# DELETE
sub destroy {
  my $c = shift;
  
  undef;
}

1;