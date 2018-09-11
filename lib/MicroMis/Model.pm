package MicroMis::Model;

use Mojo::Base -base;

use MongoDB;
use Carp qw( croak );
use FindBin;

use lib "$FindBin::Bin/../";

use MicroMis::Model::User;
use MicroMis::Model::Project;
use MicroMis::Model::Category;
use MicroMis::Model::Tag;
use MicroMis::Model::Node;
use MicroMis::Model::Log;

# db connection
my $_db;

# page size of pagination
my $_per_page;

# 初始化数据库连接，分页大小
sub init {
    my ($class, $config) = @_;

    croak 'Invalid db config'
        unless $config && $config->{host} && $config->{port} && $config->{db};

    unless ($_db) {
        my $client = MongoDB::MongoClient->new(
            host => "mongodb://$config->{host}:$config->{port}");
        $_db = $client->get_database($config->{db});
    }

    $_per_page = $config->{per_page} || 20;
}

# 数据库连接
sub db {
    return $_db if $_db;
    croak 'Init Models First!';
}

# 数据分页大小
sub per_page {
    $_per_page;
}

1;
