package MicroMis::Controller::User;
use Mojo::Base 'Mojolicious::Controller';

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
  
  my $params = $c->req->params->to_hash;
  
  my $coll = $c->db->get_collection( 'users' );
  my $oid  = $coll->insert( $params );
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