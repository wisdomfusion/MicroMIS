package MicroMis::Controller::Auth;

use strict;
use warnings;

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
  
  return $c->error(422, '提供的数据非法')
    unless ( $params->{ name } && $params->{ pass } );
  
  my $coll = $c->db->get_collection( 'users' );
  my $user = $coll->find_one( { name => lc $params->{ name }} );

  return $c->reply->not_found if !$user;

  return $c->error( 400, '用户名或密码错误' )
    unless ( MicroMis::Util::check_password( $params->{ pass }, $user->{pass} ) );
  
  my $payload = {
    oid  => $user->{ _id }->value,
    name => $user->{ name },
    exp  => time + int( $c->config( 'jwt_ttl' ) )
  };
  my $token = $c->jwt_encode( $payload );
  
  return $c->success( { token => $token } );
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

# 令牌是否有效
sub check {
  my $c = shift;
  
  my $headers       = $c->req->headers;
  my $authorization = $headers->authorization;
  
  return $c->error( 401, '未授权，未提供有效的令牌' )
    unless ( $authorization && $authorization =~ /^Bearer/ );
  
  my ( $_, $token ) = split( ' ', $authorization );
  
  if ($token) {
    $token = $c->jwt_decode($token);
    return 1 if $token->{ oid } && $token->{ name } && $token->{ exp } > time;
  }
  
  $c->error( 401,  '未授权，请登录后重试');
}

1;

=head1 NAME

MicroMis::Controller::Auth

=DESCRIPTION



=cut