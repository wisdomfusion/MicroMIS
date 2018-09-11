package MicroMis::Controller::User;

use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper qw( Dumper );
use Carp qw( croak );
use FindBin;

use lib "$FindBin::Bin/../..";
use MicroMis::Util qw( encrypt_password );

my $user_model = MicroMis::Model::User->new;

# 用户列表
# http://127.0.0.1:3000/api/v1/users
# GET
sub index {
    my $c      = shift;
    my $params = $c->req->params->to_hash;

    my $filter = {};

    unless (exists $params->{with_del}) {
        $filter->{'$or'}
            = [{deleted_at => {'$exists' => 0}}, {deleted_at => 'null'}];
    }

    my $cursor = $user_model->find($filter);
    my $total  = $user_model->count($filter);
    my $res    = $user_model->paginate($cursor, $total, $params);

    $c->success($res);
}

# 添加用户
# http://127.0.0.1:3000/api/v1/user
# POST
sub store {
    my $c = shift;

    my $v = $c->validation;
    $v->required('name');
    $v->required('pass');

    my $name = $v->param('name');
    my $pass = $v->param('pass');

    return $c->error(422, '提供的数据不合法！')
        if $v->has_error;

    return $c->error(400, '用户名已存在！')
        if $user_model->find_one({name => $name});

    my $now      = time;
    my $document = {
        name       => $name,
        pass       => encrypt_password($pass),
        created_at => $now,
        updated_at => $now,
        deleted_at => undef
    };

    my $res = $user_model->add($document);

    return $c->error(400, '添加用户失败！')
        unless $res->inserted_id;

    my $oid  = $res->inserted_id;
    my $user = $user_model->find_id($oid);
    $user->{_id} = $user->{_id}->value;

    $c->success({user => $user}, '成功添加用户！');
}

# 用户详情
# http://127.0.0.1:3000/api/v1/user/:id
# GET
sub show {
    my $c = shift;

    my $oid  = $c->oid($c->param('id'));
    my $user = $user_model->find_id($oid);

    if ($user) {
        $user->{_id} = $user->{_id}->value;
        return $c->success({user => $user});
    }

    undef;
}

# 编辑用户
# http://127.0.0.1:3000/api/v1/user/:id
# PUT
sub update {
    my $c = shift;

    my $oid    = $c->oid($c->param('id'));
    my $params = $c->req->params->to_hash;

    delete $params->{name}
        if exists $params->{name};

    $params->{pass} = encrypt_password($params->{pass})
        if exists $params->{pass};

    $params->{updated_at} = time;

    $user_model->update({_id => $oid}, {'$set' => $params});

    my $user = $user_model->find_id($oid);
    $user->{_id} = $user->{_id}->value;

    $c->success({user => $user}, '成功编辑用户！');
}

# 删除用户
# http://127.0.0.1:3000/api/v1/user/:id
# DELETE
sub destroy {
    my $c = shift;

    my $oid  = $c->oid($c->param('id'));
    my $user = $user_model->find_id($oid);

    return $c->error(403, '禁止删除根用户')
        if $user->{name} eq 'admin';

    # TODO: 用户存在 project 或 node 时禁止删除

    $user_model->delete_one({_id => $oid});

    $c->success({}, '成功删除用户！');
}

1;
