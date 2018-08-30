package MicroMis::Plugin::AppHelpers;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app) = @_;
  
  $app->helper('app_helpers.render_with_header' => sub {
    my ($c, @args) = @_;
    $c->res->headers->header('X-Mojo' => 'Mojolicious');
    $c->render(@args);
  });
}

1;
