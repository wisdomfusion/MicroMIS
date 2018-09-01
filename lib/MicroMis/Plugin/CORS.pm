package MicroMis::Plugin::CORS;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ( $self, $app, $opts ) = @_;
  
  CORS: {
    $app->hook( before_dispatch => sub {
      my $c = shift;
      $c->res->headers->header( 'Access-Control-Allow-Origin'  => '*' );
      $c->res->headers->header( 'Access-Control-Allow-Methods' => 'POST, GET, PUT, PATCH, DELETE, OPTIONS' );
      $c->res->headers->header( 'Access-Control-Max-Age'       => 3600 );
      $c->res->headers->header( 'Access-Control-Allow-Headers' => 'X-Requested-With' );
    } );
  };
}

1;