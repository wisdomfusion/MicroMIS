package MicroMis::Controller::User;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

use FindBin;
use lib "$FindBin::Bin/../..";
use MicroMis::Util;

# 用户列表
# http://127.0.0.1:3000/api/v1/users
# GET
sub index {
  my $c = shift;
  
  my $headers = $c->req->headers;
  my $auth    = $headers->authorization;
  
  my $coll   = $c->db->get_collection( 'users' );
  my @result = $coll->find()->all;
  
  $c->render(
    json   => { data => { users => \@result, token => $auth } },
    status => 200
  );
}

# 添加用户
# http://127.0.0.1:3000/api/v1/user
# POST
sub store {
  my $c = shift;
  
  my $name = $c->param( 'name' );
  my $pass = $c->param( 'pass' );
  
  my $v = $c->validation;
  $v->required( 'name' );
  $v->required( 'pass' );
  
  return $c->render(
    json => { error => 'invalid_data_provided', message => '提供的数据非法' },
    status => 422
  ) if $v->has_error;
  
  my $coll = $c->db->get_collection( 'users' );
  
  return $c->render(
    json => { error => 'username_already_exists', message => '用户名已存在' },
    status => 400
  ) if $coll->find_one( { name => $name } );
  
  my $oid  = $coll->insert_one( {
    name => $name,
    pass => MicroMis::Util::encrypt_password( $pass )
  } )->inserted_id;
  my $user = $coll->find_one( { _id => $oid } );
  
  $user->{ _id } = $user->{ _id }->value;
  
  $c->render(
    json   => { data => { user => $user }, message => '' },
    status => 200
  );
}

# 用户详情
# http://127.0.0.1:3000/api/v1/user/:id
# GET
sub show {
  my $c = shift;
  
  my $oid  = $c->value2oid( $c->param( 'id' ) );
  my $coll = $c->db->get_collection( 'users' );
  my $user = $coll->find_one( { _id => $oid } );
  
  $user->{ _id } = $user->{ _id }->value;
  
  $c->render(
    json   => { data => { user => $user }, message => '' },
    status => 200
  );
}

# 编辑用户
# http://127.0.0.1:3000/api/v1/user/:id
# PUT
sub update {
  my $c = shift;
  
  my $params = $c->req->params->to_hash;
  $params->{ _id } = $c->value2oid( $params->{ _id } );
  
  my $coll = $c->db->get_collection( 'users' );
  $coll->save( $params );
  
  my $user = $coll->find_one( { _id => $params->{ _id } } );
  $user->{ _id } = $user->{ _id }->value;
  
  $c->render(
    json   => { data => { user => $user }, message => '编辑用户成功！' },
    status => 200
  );
}

# 删除用户
# http://127.0.0.1:3000/api/v1/user/:id
# DELETE
sub destroy {
  my $c = shift;
  
  my $oid  = $c->value2oid( $c->param( 'id' ) );
  my $coll = $c->db->get_collection( 'users' );
  $coll->remove( { _id => $oid } );
  
  $c->render(
    json   => { data => { }, message => '删除用户成功！' },
    status => 200
  );
}

1;