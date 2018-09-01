package MicroMis::Plugin::AppHelpers;
use Mojo::Base 'Mojolicious::Plugin';
use Crypt::JWT qw(decode_jwt encode_jwt);
use MongoDB;
use MongoDB::OID;

sub register {
  my ( $self, $app, $opts ) = @_;
  
  # mongodb helper
  $app->helper( 'db' => sub {
    my $c = shift;
    my $mongodb_conf = $app->config( 'mongodb' );
    
    my $client = MongoDB::MongoClient->new(
      host => "mongodb://$mongodb_conf->{host}:$mongodb_conf->{port}",
    );
    my $db = $client->get_database( $mongodb_conf->{ db } );
    
    return $db;
  } );
  
  # mongodb value to oid
  $app->helper( 'value2oid' => sub {
    my ( $self, $value ) = @_;
    MongoDB::OID->new( $value );
  } );
  
  $app->helper( 'jwt_encode' => sub {
    my ( $c, $payload ) = @_;
    
    return encode_jwt(
      payload => $payload,
      alg     => 'HS256',
      key     => $app->config( 'jwt_secret' )
    );
  } );
  
  $app->helper( 'jwt_decode' => sub {
    my ( $c, $token ) = @_;
    return decode_jwt( token => $token, key => $app->config( 'jwt_secret' ) );
  } );
  
  # authenticated
  $app->helper( 'authed' => sub {
    my $c   = shift;
    my $jwt = $c->param( 'jwt' );
    
    $jwt = $c->jwt_decode( $jwt );
    
    return $jwt->{ api_key } eq $app->config( 'api_key' ) ? 1 : 0;
  } );

}

1;