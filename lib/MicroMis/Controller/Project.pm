package MicroMis::Controller::Project;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

my $project_model = MicroMis::Model::Project->new;

# project 列表
# http://127.0.0.1:3000/api/v1/projects
# GET
sub index {
  my $c = shift;
  my $params = $c->req->params->to_hash;
  
  my $filter = { };
  
  my $cursor = $project_model->find( $filter );
  my $total  = $project_model->count( $filter );
  my $res    = $project_model->paginate( $cursor, $total, $params );
  
  $c->success( $res );
}

# 添加 project
# http://127.0.0.1:3000/api/v1/project
# POST
sub store {
  my $c = shift;
  
  undef;
}

# project 详情
# http://127.0.0.1:3000/api/v1/project/:id
# GET
sub show {
  my $c = shift;
  
  undef;
}

# 编辑 project
# http://127.0.0.1:3000/api/v1/project/:id
# PUT
sub update {
  my $c = shift;
  
  undef;
}

# 删除 project
# http://127.0.0.1:3000/api/v1/project/:id
# DELETE
sub destroy {
  my $c = shift;
  
  undef;
}

# project 基本信息列表
# http://127.0.0.1:3000/api/v1/project/list
# GET
sub list {
  my $c = shift;
  
  undef;
}

# project 信息模板
# http://127.0.0.1:3000/api/v1/project/tpl
# GET
sub template {
  my $c = shift;
  
  undef;
}

1;