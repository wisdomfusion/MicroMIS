package MicroMis::Controller::Auth;

use Mojo::Base 'Mojolicious::Controller';
use Carp qw( croak );
use FindBin;
use lib "$FindBin::Bin/../..";
use MicroMis::Util qw( check_password );

my $coll_users = MicroMis::Model->db->get_collection('users');

# 登录接口
# http://127.0.0.1:3000/api/v1/login
# POST
sub login {
    my $c      = shift;
    my $params = $c->req->params->to_hash;

    my $v = $c->validation;
    $v->input($params);
    $v->required('name');
    $v->required('pass');

    return $c->error(422, '提供的数据不合法')
        if $v->has_error;

    my ($name, $pass) = ($v->param('name'), $v->param('pass'));

    my $user = $coll_users->find_one({name => lc $name});

    return $c->reply->not_found if !$user;

    return $c->error(400, '用户名或密码错误')
        unless (check_password($pass, $user->{pass}));

    my $payload = {
        oid  => $user->{_id}->value,
        name => $user->{name},
        exp  => time + int($c->config('jwt_ttl'))
    };
    my $token = $c->jwt_encode($payload);

    return $c->success({token => $token});
}

# 退出接口
# http://127.0.0.1:3000/api/v1/logout
# POST
sub logout {
    my ($c, $token) = shift;

    return undef;
}

# 更新 token 接口
# http://127.0.0.1:3000/api/v1/renew_token
# POST
sub renew_token {
    my $c = shift;

    my $headers       = $c->req->headers;
    my $authorization = $headers->authorization;

    return $c->error(401, '未授权，未提供有效的令牌')
        unless ($authorization && $authorization =~ /^Bearer/);

    my ($_, $token) = split(' ', $authorization);

    if ($token) {
        $token = $c->jwt_decode($token);

        if (   exists $token->{oid}
            && exists $token->{name}
            && exists $token->{exp})
        {
            my $payload = {
                oid  => $token->{oid},
                name => $token->{name},
                exp  => time + int($c->config('jwt_ttl'))
            };

            my $new_token = $c->jwt_encode($payload);
            return $c->success({token => $new_token});
        }
    }

    0;
}

# 令牌是否有效
sub check {
    my $c = shift;

    return 1 if $c->authed;

    $c->error(401, '未授权，请登录后重试');

    0;
}

1;
