package MicroMis::Controller::Category;

use Mojo::Base 'Mojolicious::Controller';
use Carp qw( croak );

my $cate_model = MicroMis::Model::Category->new;

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
  my $params = $c->req->params->to_hash;
  
  my $v = $c->validation;
  $v->input( $params );
  $v->required( 'title' )->size( 2, 20 );
  
  return $c->error( 422, '提供的数据不合法！' )
    if $v->has_error;
  
  my $title = $v->param( 'title' );
  my $pid   = $params->{ pid } || undef;
  
  my $document = {
    title    => $title,
    pid      => $pid,
    children => [ ],
    order    => 0,
  };
  
  if ( $pid ) {
    my $opid = $c->oid( $pid );
    
    return $c->error( 400, '同一主分类下子分类名称不能相同！' )
      if $cate_model->count( { pid => $opid, title => $title } );
    
    $document->{ pid } = $opid;
    my $res = $cate_model->add( $document );
  
    return $c->error( 400, '添加分类失败！' )
      unless $res->inserted_id;
    
    if ( $res->inserted_id ) {
      $cate_model->update( { _id => $opid }, { '$push' => { children => $res->inserted_id } } );
      $c->success( { }, '成功添加分类！' );
    }
  }
  else {
    return $c->error( 400, '主分类名称已存在！' )
      if $cate_model->count( { title => $title } );
    
    my $res = $cate_model->add( $document );
  
    return $c->error( 400, '添加分类失败！' )
      unless $res->inserted_id;
    
    $c->success( { }, '成功添加分类！' );
  }

  undef;
}

# 编辑分类
# http://127.0.0.1:3000/api/v1/cate/:id
# PUT
sub update {
  my $c = shift;
  my $params = $c->req->params->to_hash;
  
  
  
  undef;
}

# 分类排序
# http://127.0.0.1:3000/api/v1/cates/sort
# POST
sub sort {
  my $c = shift;
  my $params = $c->req->params->to_hash;
  
  undef;
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