package MicroMis::Plugin::AppHelpers;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::JWT;
use MongoDB;
use MongoDB::OID;

sub register {
  my ($self, $app) = @_;
  
  # mongodb helper
  $app->helper('db' => sub {
    my $c = shift;
    my $mongodb_conf = $app->config('mongodb');
    
    my $client = MongoDB::MongoClient->new(
      host => "mongodb://$mongodb_conf->{host}:$mongodb_conf->{port}",
    );
    my $db = $client->get_database($mongodb_conf->{db});
    
    return $db;
  });
  
  # mongodb oid
  $app->helper('value2oid' => sub {
    my ($self, $value) = @_;
    MongoDB::OID->new($value);
  });
  
  # jwt
  $app->helper('jwt_encode' => sub {
    my $c       = shift;
    my $payload = shift // { };
    
    return Mojo::JWT->new({
      claims => $payload,
      secret => $app->config('jwt_secret')
    })->encode;
  });
  
  # jwt
  $app->helper('jwt_decode' => sub {
    my ($c, $jwt) = @_;
    
    return Mojo::JWT->new($app->config('jwt_secret'))->decode($jwt);
  });
  
  # authenticated
  $app->helper('authed' => sub {
    my $c   = shift;
    my $jwt = $c->param('jwt');
    
    $jwt = $c->jwt_decode($jwt);
    
    return $jwt->{api_key} eq $app->config('api_key') ? 1 : 0;
  });

}

1;