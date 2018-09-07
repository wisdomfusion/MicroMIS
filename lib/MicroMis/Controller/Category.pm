package MicroMis::Controller::Category;

use Mojo::Base 'Mojolicious::Controller';

our $cate_model = MicroMis::Model::Category->new;

# 分类列表
# http://127.0.0.1:3000/api/v1/cates
# GET
sub index {
  my $c = shift;
  
  my @result = $cate_model->find->all;
  $c->success( { categories => \@result } );
}

# 添加分类
# http://127.0.0.1:3000/api/v1/cate
# POST
sub store {
  my $c = shift;
  
  my $title = $c->param( 'title' );
  my $pid   = $c->param( 'pid' ) || undef;
  
  my $v = $c->validation;
  $v->required( 'title' );
  
  return $c->error( 422, '提供的数据不合法！' )
    if $v->has_error;
  
  return $c->error( 400, '主分类名称已存在！' )
    if ( !$pid && $cate_model->count( { title => $title } ) );
  
  return $c->error( 400, '同一主分类下子分类名称不能相同！' )
    if ( $pid && $cate_model->count( { pid => $pid, title => $title } ) );
  
  my $document = {
    title => $title,
    pid   => $pid,
    order => 0,
  };
  
  my $res = $cate_model->add( $document );
  
  return $c->error( 400, '添加分类失败！' )
    unless $res->inserted_id;
  
  my @categories = $cate_model->find( { }, { sort => { order => 1 } } )->all;
  $c->success( { categories => \@categories }, '成功添加分类！' );
}

# 删除分类
# http://127.0.0.1:3000/api/v1/cate
# DELETE
sub destroy {
  my $c = shift;
  
  my $cate_id  = $c->param( 'id ') || '';
  my $node_num = MicroMis::Model::Node->count( { cate_id => $cate_id } );
  
  return $c->error( 400, '该分类下存在有效信息，无法删除！' )
    if $node_num;
  
  my $oid = $c->oid( $cate_id );
  
  $cate_model->delete_one( { _id => $oid } );
  
  $c->success( { }, '成功删除分类！' );
}

1;