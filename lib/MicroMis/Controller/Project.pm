package MicroMis::Controller::Project;

use Mojo::Base 'Mojolicious::Controller';

my $project_model = MicroMis::Model::Project->new;

# project 列表
# http://127.0.0.1:3000/api/v1/projects
# GET
sub index {
    my $c      = shift;
    my $params = $c->req->query_params->to_hash;

    my $filter = {};

    my $cursor = $project_model->find($filter);
    my $total  = $project_model->count($filter);
    my $res    = $project_model->paginate($cursor, $total, $params);

    $c->success($res);
}

# 添加 project
# http://127.0.0.1:3000/api/v1/project
# POST
sub store {
    my $c      = shift;
    my $params = $c->req->body_params->to_hash;

    my $v = $c->validation;
    $v->required('title', 'trim')->size(2, 20);
    $v->required('slug', 'trim')->size(2, 20);
    $v->required('fields');
    $v->optional('description');

    return $c->error(422, '提供的数据不合法！')
        if $v->has_error;

    my $now      = time;
    my $document = $v->output;
    $document->{created_at} = $now;
    $document->{updated_at} = $now;
    $document->{deleted_at} = undef;

    my $res = $project_model->add($document);

    return $c->error(400, '添加 Project 失败！')
        unless $res->inserted_id;

    my $project = $project_model->find_id($res->inserted_id);
    $project->{_id} = $project->{_id}->value;

    $c->success({project => $project}, '成功添加 Project！');
}

# project 详情
# http://127.0.0.1:3000/api/v1/project/:id
# GET
sub show {
    my $c = shift;

    my $project_id = $c->param('id');

    return $c->error(422, '提供的数据不合法！')
        if !$project_id || $project_id !~ qr/^[a-f\d]{24}$/;


    my $project = $project_model->find_id($c->oid($project_id));

    if ($project) {
        $project->{_id} = $project->{id}->value;
        return $c->success({project => $project});
    }

    undef;
}

# 编辑 project
# http://127.0.0.1:3000/api/v1/project/:id
# PUT
sub update {
    my $c = shift;

    my $oid    = $c->oid($c->param('id'));
    my $params = $c->req->body_params->to_hash;

    my $v = $c->validation;
    $v->optional('title', 'trim')->size(2, 20);
    $v->optional('slug',  'trim')->size(2, 20);
    $v->optional('description');

    return $c->error(422, '提供的数据不合法！')
        if $v->has_error;

    my $update_params = {};

    $update_params->{title} = $v->output('title')
        if exists $params->{title};

    $update_params->{slug} = $v->output('slug')
        if exists $params->{slug};

    $update_params->{description} = $v->output('description')
        if exists $params->{description};

    $update_params->{updated_at} = time;

    my $res
        = $project_model->update({_id => $oid}, {'$set' => $update_params});

    return $c->error(400, '编辑 Project 失败！')
        unless $res->acknowleged;

    my $project = $project_model->find_id($oid);
    $project->{_id} = $project->{_id}->value;

    $c->success({project => $project}, '成功编辑 Project！');
}

# 删除 project
# http://127.0.0.1:3000/api/v1/project/:id
# DELETE
sub destroy {
    my $c = shift;

    my $project_id = $c->param('id');

    my $node_count
        = MicroMis::Model::Node->count({project_id => $project_id});
    return $c->error(400, '该 Project 下存在有效信息，无法删除！')
        if $node_count;

    my $res = $project_model->delete_one({_id => $c->oid($project_id)});

    return $c->error(400, '删除 Project失败！')
        unless $res->acknowleged;

    $c->success({}, '成功删除 Project！');
}

# project 基本信息列表
# http://127.0.0.1:3000/api/v1/project/list
# GET
sub list {
    my $c = shift;

    my @projects
        = $project_model->find({})->fields({_id => 1}, {title => 1});

    $c->success({projects => \@projects});
}

# project 信息模板
# http://127.0.0.1:3000/api/v1/project/tpl
# GET
sub template {
    my $c = shift;

    undef;
}

1;
