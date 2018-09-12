package MicroMis::Controller::Category;

use Mojo::Base 'Mojolicious::Controller';
use Storable qw( dclone );
use Carp qw( croak );

my $cate_model = MicroMis::Model::Category->new;

# 分类列表
# http://127.0.0.1:3000/api/v1/cates
# GET
sub index {
    my $c = shift;

    my @cates
        = $cate_model->find(
        {'$or' => [{pid => {'$exists' => 0}}, {pid => ''}, {pid => undef}]})
        ->all;

    my @result = ();
    for my $cate (@cates) {
        $cate->{children} = ();

        my $sub_count = $cate_model->count({pid => $cate->{_id}});
        if ($sub_count) {
            my @children = $cate_model->find({pid => $cate->{_id}})->all;

            for my $sub (@children) {
                push @{$cate->{children}}, $sub;
            }
        }
        push @result, $cate;
    }

    $c->success(\@result);
}

# 添加分类
# http://127.0.0.1:3000/api/v1/cate
# POST
sub store {
    my $c      = shift;
    my $params = $c->req->params->to_hash;

    my $v = $c->validation;
    $v->input($params);
    $v->required('title', 'trim')->size(2, 20);
    $v->optional('pid', 'trim')->like(qr/^[a-f\d]{24}$/);

    return $c->error(422, '提供的数据不合法！')
        if $v->has_error;

    my $title = $v->param('title');
    my $pid = $v->param('pid') || undef;

    my $document = {
        title => $title,
        pid   => $pid ? $c->oid($pid) : undef,
        order => 0,
    };

    if ($pid) {
        my $children_count
            = $cate_model->count({pid => $c->oid($pid), title => $title});
        return $c->error(400, '同一主分类下子分类名称不能相同！')
            if $children_count;
    }
    else {
        my $cate_count = $cate_model->count(
            {   '$or' =>
                    [{pid => {'$exists' => 0}}, {pid => ''}, {pid => undef}],
                title => $title
            }
        );
        return $c->error(400, '主分类名称已存在！')
            if $cate_count;
    }

    my $res = $cate_model->add($document);

    return $c->error(400, '添加分类失败！')
        unless $res->inserted_id;

    $c->success({}, '成功添加分类！');
}

# 编辑分类
# http://127.0.0.1:3000/api/v1/cate/:id
# PUT
sub update {
    my $c      = shift;
    my $oid    = $c->oid($c->param('id'));
    my $params = $c->req->params->to_hash;

    my $v = $c->validation;
    $v->input($params);
    $v->optional('pid', 'trim')->like(qr/^[a-f\d]{24}$/);
    $v->optional('title', 'trim')->size(2, 20);

    my $new_pid = $v->param('pid')   || undef;
    my $title   = $v->param('title') || undef;

    return $c->error(422, '提供的数据不合法！')
        if $v->has_error || (!$new_pid && !$title);

    # 当前编辑的分类
    my $cate = $cate_model->find_id($oid);

    return $c->error(404, '指定父级分类不存在！')
        unless $cate_model->count({_id => $c->oid($new_pid)});

    # 编辑分类
    my $update = {};
    $update->{pid}   = $c->oid($new_pid) unless !$new_pid;
    $update->{title} = $title            unless !$title;
    $cate_model->update({_id => $oid}, {'$set' => $update});

    $c->success({}, '编辑分类成功！');
}

# 分类排序
# http://127.0.0.1:3000/api/v1/cates/sort
# POST
sub sort {
    my $c      = shift;
    my $params = $c->req->params->to_hash;

    undef;
}

# 删除分类
# http://127.0.0.1:3000/api/v1/cate/:id
# DELETE
sub destroy {
    my $c = shift;

    my $cate_id = $c->param('id ') || undef;

    return $c->error(422, '提供的数据不合法！')
        if !$cate_id || $cate_id !~ qr/^[a-f\d]{24}$/;

    my $node_num
        = MicroMis::Model::Node->count({cate_id => $c->oid($cate_id)});

    return $c->error(400, '该分类下存在有效信息，无法删除！')
        if $node_num;

    $cate_model->delete_one({_id => $c->oid($cate_id)});

    $c->success({}, '成功删除分类！');
}

1;
