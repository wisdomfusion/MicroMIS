package MicroMis;

use strict;
use warnings;

our $VERSION = '0.0.1';

use Mojo::Base 'Mojolicious';

use MicroMis::Plugin::AppHelpers;
use MicroMis::Model;

sub startup {
  my $self = shift;

  # config
  $self->plugin( 'Config' => { file => 'app.conf' } );
  
  # helpers
  $self->plugin( 'MicroMis::Plugin::AppHelpers' );
  
  # client folder './public'
  $self->static->path->[0] = './public';
  
  $self->plugin( 'MicroMis::Plugin::CORS' );

  #
  # 路由：
  #
  my $r = $self->routes;
  $r->any( '/' => sub { $_[0]->reply->static( 'index.html' ) } );
  
  #
  # API 路由：
  #
  my $api = $r->under( '/api/v1' );
  $api->post( '/login' )->to( 'auth#login' );             # 登录
  $api->post( '/logout' )->to( 'auth#logout' );           # 退出
  $api->post( '/token/renew' )->to( 'auth#renew_token' ); # 更新令牌
  
  #
  # 登录验证后：
  #
  my $authed = $api->under( '/' )->to( 'auth#check' );

  # 用户
  $authed->get( '/users' )->to( 'user#index' );
  $authed->post( '/user' )->to( 'user#store' );
  $authed->get( '/user/:id' )->to( 'user#show' );
  $authed->put( '/user/:id' )->to( 'user#update' );
  $authed->delete( '/user/:id' )->to( 'user#destroy' );
  
  # 项目
  $authed->get( '/projects' )->to( 'project#index' );
  $authed->post( '/project' )->to( 'project#store' );
  $authed->get( '/project/:id' )->to( 'project#show' );
  $authed->put( '/project/:id' )->to( 'project#update' );
  $authed->delete( '/project/:id' )->to( 'project#destroy' );
  $authed->get( '/project/list' )->to( 'project#list' );
  
  # 标签
  $authed->get( '/tags' )->to( 'tag#index' );
  
  # 分类（行业）
  $authed->get( '/cates' )->to( 'category#index' );
  $authed->post( '/cate' )->to( 'category#store' );
  $authed->delete( '/cate/:id' )->to( 'category#destroy' );
  
  # 信息节点
  $authed->get( '/nodes' )->to( 'node#index' );
  $authed->post( '/node' )->to( 'node#store' );
  $authed->get( '/node/:id' )->to( 'node#show' );
  $authed->put( '/node/:id' )->to( 'node#update' );
  $authed->delete( '/node/:id' )->to( 'node#destroy' );
  
  # 系统日志
  $authed->get( '/logs' )->to( 'log#index' );
  
  # Init Model
  MicroMis::Model->init( $self->config( 'mongodb' ) || {
    host => 'localhost',
    port => 27017,
    db   => 'micromisdb'
  });
}

1;

=head1 NAME

MicroMis - Micro Management Information System for information with dynamic fields, using Perl and Mojolicious, with MongoDB as backend database.

=head1 DESCRIPTION



=cut
