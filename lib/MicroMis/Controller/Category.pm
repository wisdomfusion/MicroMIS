package MicroMis::Controller::Category;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $c = shift;
  
  my $categories = $c->db->get_collection('categories');
  my @result = $categories->find({ });
  
  $c->render(
    json   => { categories => \@result },
    status => 200
  );
}

sub store {
  my $c = shift;
  
  return undef;
}

sub destroy {
  my $c = shift;
  
  return undef;
}

1;