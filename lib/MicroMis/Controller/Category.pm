package MicroMis::Controller::Category;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

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
  
  my $title      = $c->param( 'title' );
  my $parent_oid = $c->param( 'parent_oid ') || undef;
  
  my $v = $c->validation;
  $v->required( 'title' );
  
  return $c->error( 422, '提供的数据不合法！' )
    if $v->has_error;
  
  return $c->error( 400, '主分类名称已存在！' )
    if !$parent_oid && $cate_model->find_one( { title => $title } );
  
  my $flag = 0; # 添加成功与否
  
  my $q;
  if ( $parent_oid ) {
    # 添加子分类
    $q = $cate_model->find_id( $c->oid( $parent_oid ) );
    
    if ( length $q->{ children } ) {
      my %children = map { $_ => 1 } $q->{ children };
      
      return $c->error( 400, '同一主分类下子分类名称不能相同！' )
        if ( exists $children{ $title } );
    }
    
    my $filter = { _id => $c->oid( $parent_oid ) };
    my $update = { '$push' => { children => $title } };
      
    $flag = 1 if ( $cate_model->update( $filter, $update )->acknowledged );
  }
  else {
    # 添加主分类
    my $document = {
      title      => $title,
      children   => [ ],
      order      => 0,
    };
    
    $q = $cate_model->add( $document );
    
    $flag = 1 if ( $q->inserted_id );
  }
  
  if ( $flag ) {
    my @categories = $cate_model->find( { }, { sort => { order => 1 } } )->all;
    return $c->success( { categories => \@categories }, '成功添加分类！' );
  }
  
  $c->error( 400, '添加分类失败！' );
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