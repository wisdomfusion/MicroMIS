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
  
  my $name = $c->param( 'name' ) // '';
  my $pass = $c->param( 'pass' ) // '';
  
  my $users  = $c->db->get_collection( 'users' );
  my $result = $users->find_one( { name => lc $name} );
  
  return $c->render(
    json => { error => 'user_doesnot_exists', message => '用户不存在' },
    status => 404
  ) if !$result;

  unless ( MicroMis::Util::check_password( $pass, $result->{pass} ) ) {
    return $c->render(
      json => {
        error   => 'invalid_email_or_password',
        message => '用户名或密码错误'
      },
      status => 400
    );
  }
  
  my $payload = {
    sub => $result->{ name },
    exp => time + int( $c->config( 'jwt_ttl' ) )
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