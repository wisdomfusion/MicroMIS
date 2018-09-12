package MicroMis::Controller::Node;

use Mojo::Base 'Mojolicious::Controller';
use Carp qw( croak );
use Data::Dumper qw( Dumper );

my $node_model = MicroMis::Model::Node->new;

# 信息列表
# http://127.0.0.1:3000/api/v1/nodes
# GET
sub index {
    my $c      = shift;
    my $params = $c->req->query_params->to_hash;

    my $filter = {};

    my $cursor = $node_model->find($filter);
    my $total  = $node_model->count($filter);
    my $res    = $node_model->paginate($cursor, $total, $params);

    $c->success($res);
}

# 导入信息节点
# http://127.0.0.1:3000/api/v1/nodes
# POST
sub import {
    my $c = shift;

    undef;
}

# 添加信息节点
# http://127.0.0.1:3000/api/v1/node
# POST
sub store {
    my $c = shift;

    my $params = $c->req->body_params->to_hash;
    my $v = $c->validation;
    $v->input($params);
    $v->required('title', 'trim')->size(2, 80);
    $v->required('project_id', 'trim')->like(qr/^[a-f\d]{24}$/);
    $v->required('categories');
    $v->optional('tags');
    $v->optional('fields');

    return $c->error(422, '提供的数据不合法！')
        if $v->has_error;

    my $document = $v->output;
    my $now = time;
    $document->{created_at} = $now;
    $document->{updated_at} = $now;
    $document->{deleted_at} = undef;

    my $res = $node_model->add($document);

    return $c->error(400, '信息添加失败！')
        unless $res->inserted_id;

    my $node = $node_model->find_id($res->inserted_id);

    $c->success({node => $node}, '信息添加成功！');
}

# 信息节点详情
# http://127.0.0.1:3000/api/v1/node/:id
# GET
sub show {
    my $c = shift;

    my $node_id = $c->param('id');

    return $c->error(422, '提供的数据不合法！')
        if !$node_id || $node_id !~ qr/^[a-f\d]{24}$/;

    my $node = $node_model->find_id($c->oid($node_id));

    if ($node) {
        $node->{_id} = $node->{_id}->value;
        return $c->success({node => $node});
    }

    undef;
}

# 编辑信息节点
# http://127.0.0.1:3000/api/v1/node/:id
# PUT
sub update {
    my $c      = shift;
    my $oid    = $c->oid($c->param('id'));
    my $params = $c->req->body_params->to_hash;

    my $v = $c->validation;
    $v->input($params);
    $v->optional('title', 'trim')->size(2, 80);
    $v->optional('project_id', 'trim')->like(qr/^[a-f\d]{24}$/);
    $v->optional('categories');
    $v->optional('tags');
    $v->optional('fields');

    return $c->error(422, '提供的数据不合法！')
        if $v->has_error;

    my $update_params = $v->output;
    $update_params->{updated_at} = time;

    my $res = $node_model->update({_id => $oid}, {'$set' => $update_params});

    return $c->error(400, '编辑信息失败！')
        unless $res->acknowleged;

    my $node = $node_model->find_id($oid);
    $node->{_id} = $node->{_id}->value;

    $c->success({node => $node}, '编辑信息成功！');
}

# 删除信息节点
# http://127.0.0.1:3000/api/v1/node/:id
# DELETE
sub destroy {
    my $c   = shift;
    my $oid = $c->param('id') ? $c->oid($c->param('id')) : undef;

    my $res = $node_model->delete_one({_id => $oid});

    return $c->error(400, '删除信息失败！')
        unless $res->acknowleged;

    $c->success({}, '删除信息成功！');
}

1;
