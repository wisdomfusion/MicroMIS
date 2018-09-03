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
  my @result = $coll->find->all;
  
  $c->success( { users => \@result, token => $auth } );
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
  return $c->error( 422, '提供的数据非法' ) if $v->has_error;
  
  my $coll = $c->db->get_collection( 'users' );
  
  return $c->error( 400, '用户名已存在！' )
    if $coll->find_one( { name => $name } );
  
  my $result = $coll->insert_one( {
    name => $name,
    pass => MicroMis::Util::encrypt_password( $pass )
  } );
  
  return $c->error( 400, '添加用户失败！' )
    unless $result->inserted_id;
    
  my $oid  = $result->inserted_id;
  my $user = $coll->find_one( { _id => $oid }, { pass => 0 } );
  $user->{ _id } = $user->{ _id }->value;
  
  my $res = { user => $user };
  
  $c->success( $res, '成功添加用户！' );
}

# 用户详情
# http://127.0.0.1:3000/api/v1/user/:id
# GET
sub show {
  my $c = shift;
  
  my $oid  = $c->value2oid( $c->param( 'id' ) );
  my $coll = $c->db->get_collection( 'users' );
  my $user = $coll->find_id( $oid, { pass => 0 } );
  $user->{ _id } = $user->{ _id }->value;
  
  my $res = { user => $user };
  
  $c->success( $res );
}

# 编辑用户
# http://127.0.0.1:3000/api/v1/user/:id
# PUT
sub update {
  my $c = shift;
  
  my $oid    = $c->value2oid( $c->param( 'id' ) );
  my $params = $c->req->params->to_hash;
  
  delete $params->{ name }
    if ( exists $params->{ name } );
    
  $params->{ pass } = MicroMis::Util::encrypt_password( $params->{ pass } )
    if ( exists $params->{ pass } );
    
  $params->{ updated_at } = time;
  
  my $coll = $c->db->get_collection( 'users' );
  $coll->update_one( { _id => $oid }, { '$set' => $params } );
  
  my $user = $coll->find_id( $oid, { pass => 0 } );
  $user->{ _id } = $user->{ _id }->value;
  
  my $res = { user => $user };
  
  $c->success( $res, '成功编辑用户！' );
}

# 删除用户
# http://127.0.0.1:3000/api/v1/user/:id
# DELETE
sub destroy {
  my $c = shift;
  
  my $oid  = $c->value2oid( $c->param( 'id' ) );
  
  my $coll = $c->db->get_collection( 'users' );
  my $user = $coll->find_id( $oid );
  
  return $c->error(403, '禁止删除根用户')
    if $user->{ name } eq 'admin';
  
  # TODO: 用户存在 project 或 node 时禁止删除
  
  $coll->delete_one( { _id => $oid } );
  
  $c->success( { }, '成功删除用户！' );
}

1;