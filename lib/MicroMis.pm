package MicroMis;

use Mojo::Base 'Mojolicious';

use MicroMis::Plugin::AppHelpers;
use MicroMis::Model;

our $VERSION = '0.0.2';

sub startup {
    my $self = shift;

    # config
    $self->plugin( 'Config' => { file => 'app.conf' } );

    # helpers
    $self->plugin('MicroMis::Plugin::AppHelpers');

    # client folder './public'
    $self->static->path->[0] = './public';

    $self->plugin('MicroMis::Plugin::CORS');

    #
    # 路由：
    #
    my $r = $self->routes;
    $r->any( '/' => sub { $_[0]->reply->static('index.html') } );

    #
    # API 路由：
    #
    my $api = $r->under('/api/v1');

    $api->route('/login'      )->via('POST')->to('auth#login');
    $api->route('/logout'     )->via('POST')->to('auth#logout');
    $api->route('/token/renew')->via('POST')->to('auth#renew_token');

    #
    # 登录验证后：
    #
    my $authed = $api->under('/')->to('auth#check');

    # 用户
    $authed->route('/users'   )->via('GET'   )->to('user#index');
    $authed->route('/user'    )->via('POST'  )->to('user#store');
    $authed->route('/user/:id')->via('GET'   )->to('user#show');
    $authed->route('/user/:id')->via('PUT'   )->to('user#update');
    $authed->route('/user/:id')->via('DELETE')->to('user#destroy');

    # 项目
    $authed->route('/projects'    )->via('GET'   )->to('project#index');
    $authed->route('/project'     )->via('POST'  )->to('project#store');
    $authed->route('/project/list')->via('GET'   )->to('project#list');
    $authed->route('/project/tpl' )->via('GET'   )->to('project#template');
    $authed->route('/project/:id' )->via('GET'   )->to('project#show');
    $authed->route('/project/:id' )->via('PUT'   )->to('project#update');
    $authed->route('/project/:id' )->via('DELETE')->to('project#destroy');

    # 标签
    $authed->route('/tags')->via('GET')->to('tag#index');

    # 分类（行业）
    $authed->route('/cates'     )->via('GET'   )->to('category#index');
    $authed->route('/cates/sort')->via('GET'   )->to('category#sort');
    $authed->route('/cate'      )->via('POST'  )->to('category#store');
    $authed->route('/cate/:id'  )->via('PUT'   )->to('category#update');
    $authed->route('/cate/:id'  )->via('DELETE')->to('category#destroy');

    # 信息节点
    $authed->route('/nodes'      )->via('GET'   )->to('node#index');
    $authed->route('/node'       )->via('POST'  )->to('node#store');
    $authed->route('/node/import')->via('POST'  )->to('node#import');
    $authed->route('/node/:id'   )->via('GET'   )->to('node#show');
    $authed->route('/node/:id'   )->via('PUT'   )->to('node#update');
    $authed->route('/node/:id'   )->via('DELETE')->to('node#destroy');

    # 系统日志
    $authed->route('/logs')->via('GET')->to('log#index');

    # Init Model
    MicroMis::Model->init(
        $self->config('mongodb')
            || {
                host => 'localhost',
                port => 27017,
                db   => 'micromisdb'
            }
    );
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

MicroMis - Micro Management Information System for information with dynamic fields, using Perl and Mojolicious, with MongoDB as backend database.

=head1 DESCRIPTION



=cut
