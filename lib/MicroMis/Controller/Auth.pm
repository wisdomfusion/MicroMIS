package MicroMis::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller';
use FindBin;
use lib "$FindBin::Bin/../..";
use MicroMis::Util;

# 登录接口
sub login {
  my $c = shift;
  
  my $name = $c->param('name') // '';
  my $pass = $c->param('pass') // '';
  
  my $users = $c->db->get_collection('users');
  my $user  = $users->find_one({ name => lc $name});
  
  return $c->render(
    json => { error => 'user_doesnot_exists', message => '用户不存在' },
    status => 404
  ) if !$user;

  unless(MicroMis::Util::check_password($pass, $user->{pass})) {
    return $c->render(
      json => {
        error   => 'invalid_email_or_password',
        message => '用户名或密码错误'
      },
      status => 400
    );
  }
  
  my $payload = {
    sub => $user->{name},
    exp => time + int($c->config('jwt_ttl'))
  };
  my $token = $c->jwt_encode($payload);
  
  return $c->render(json => { token => $token }, status => 200);
}

# 退出接口
sub logout {
  my $c = shift;
  
  return undef;
}

# 更新 jwt 接口
sub renew_token {
  my $c = shift;
  
  return undef;
}

1;