package MicroMis::Plugin::AppHelpers;

use Mojo::Base 'Mojolicious::Plugin';
use Crypt::JWT qw(decode_jwt encode_jwt);
use MongoDB;
use BSON::Types qw( bson_oid );

sub register {
  my ( $self, $app, $opts ) = @_;
  
  # mongodb helper
  $app->helper( 'db' => sub {
    my $c = shift;
    my $mongodb_conf = $app->config( 'mongodb' );
    
    my $client = MongoDB::MongoClient->new(
      host => "mongodb://$mongodb_conf->{host}:$mongodb_conf->{port}",
    );
    state $db = $client->get_database( $mongodb_conf->{ db } );
    
    return $db;
  } );
  
  # mongodb oid 的值转成 12 字节的 ObjectId
  # https://docs.mongodb.com/manual/reference/method/ObjectId/
  $app->helper( 'oid' => sub {
    my ( $self, $oid_string ) = @_;
    bson_oid( $oid_string );
  } );
  
  # jwt 编码
  $app->helper( 'jwt_encode' => sub {
    my ( $c, $payload ) = @_;
    
    return encode_jwt(
      payload => $payload,
      alg     => 'HS256',
      key     => $app->config( 'jwt_secret' )
    );
  } );
  
  # jwt 解码
  $app->helper( 'jwt_decode' => sub {
    my ( $c, $token ) = @_;
    return decode_jwt( token => $token, key => $app->config( 'jwt_secret' ) );
  } );
  
  # 已授权？
  $app->helper( 'authed' => sub {
    my $c = shift;
    
    my $headers       = $c->req->headers;
    my $authorization = $headers->authorization;
    
    return 0 if ( !$authorization || $authorization !~ /^Bearer/ );
    
    my ( $_, $token ) = split( ' ', $authorization );
    if ($token) {
      $token = $c->jwt_decode($token);
      return 1 if $token->{ oid } && $token->{ name } && $token->{ exp } > time;
    }
    
    0;
  } );
  
  # 请求成功的 response
  # $c->success( data, message )
  $app->helper( 'success' => sub {
    my ( $c, $data, $message ) = @_;
    
    $data    = $data    || { };
    $message = $message || '';
    
    $c->render(
      json   => { data => $data, message => $message },
      status => 200
    );
  } );
  
  # 请求失败的 response
  # $c->( status, message, data )
  $app->helper( 'error' => sub {
    my $c = shift;
    
    my $status  = shift || 400;
    my $message = shift || '400 Bad Request';
    my $data    = shift || { };
    
    my $res = { message => $message };
    $res->{ data } = $data if $data;
    
    $c->render( json => $res, status => $status );
  } );

}

1;