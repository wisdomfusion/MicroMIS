package MicroMis::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller';

use FindBin;
use lib "$FindBin::Bin/../..";
use MicroMis::Util;

# 登录接口
# http://127.0.0.1:3000/api/v1/login
# POST
sub login {
  my $c = shift;
  my $params = $c->req->params->to_hash;
  
  return $c->render(
    json => { error => 'invalid_data_provided', message => '提供的数据非法' },
    status => 422
  ) unless ( $params->{ name } && $params->{ pass } );
  
  my $coll = $c->db->get_collection( 'users' );
  my $user = $coll->find_one( { name => lc $params->{ name }} );

  return $c->render(
    json => { error => 'user_doesnot_exists', message => '用户不存在' },
    status => 404
  ) if !$user;

  unless ( MicroMis::Util::check_password( $params->{ pass }, $user->{pass} ) ) {
    return $c->render(
      json => {
        error   => 'invalid_email_or_password',
        message => '用户名或密码错误'
      },
      status => 400
    );
  }
  
  my $payload = {
    oid  => $user->{ _id }->value,
    name => $user->{ name },
    exp  => time + int( $c->config( 'jwt_ttl' ) )
  };
  my $token = $c->jwt_encode( $payload );
  
  return $c->render( json => { token => $token }, status => 200 );
}

# 退出接口
# http://127.0.0.1:3000/api/v1/logout
# POST
sub logout {
  my $c = shift;
  
  return undef;
}

# 更新 token 接口
# http://127.0.0.1:3000/api/v1/renew_token
# POST
sub renew_token {
  my $c = shift;
  
  return undef;
}

1;