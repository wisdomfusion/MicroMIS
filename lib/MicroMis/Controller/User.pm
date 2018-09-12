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
    my $params = $c->req->query_params->to_hash;

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
    $v->required('name', 'trim')->size(2, 20);
    $v->required('pass', 'trim')->size(6, 20);

    return $c->error(422, '提供的数据不合法！')
        if $v->has_error;

    my $name = $v->param('name');
    my $pass = $v->param('pass');

    return $c->error(400, '用户名已存在，无法添加！')
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

    return $c->error(400, '用户添加失败！')
        unless $res->inserted_id;

    my $user = $user_model->find_id($res->inserted_id);
    $user->{_id} = $user->{_id}->value;

    $c->success({user => $user}, '用户添加成功！');
}

# 用户详情
# http://127.0.0.1:3000/api/v1/user/:id
# GET
sub show {
    my $c = shift;

    my $user_id = $c->param('id');

    return $c->error(422, '提供的数据不合法！')
        if !$user_id || $user_id !~ qr/^[a-f\d]{24}$/;

    my $user = $user_model->find_id($c->oid($user_id));

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
    my $params = $c->req->body_params->to_hash;

    delete $params->{name}
        if exists $params->{name};

    $params->{pass} = encrypt_password($params->{pass})
        if exists $params->{pass};

    $params->{updated_at} = time;

    my $res = $user_model->update({_id => $oid}, {'$set' => $params});

    return $c->error(400, '编辑用户失败！')
        unless $res->acknowleged;

    my $user = $user_model->find_id($oid);
    $user->{_id} = $user->{_id}->value;

    $c->success({user => $user}, '编辑用户成功！');
}

# 删除用户
# http://127.0.0.1:3000/api/v1/user/:id
# DELETE
sub destroy {
    my $c   = shift;
    my $oid = $c->param('id') ? $c->oid($c->param('id')) : undef;

    my $user = $user_model->find_id($oid);

    return $c->error(403, '禁止删除根用户')
        if $user->{name} eq 'admin';

    my $res = $user_model->delete_one({_id => $oid});

    return $c->error(400, '删除用户失败！')
        unless $res->acknowleged;

    $c->success({}, '成功删除用户！');
}

1;
