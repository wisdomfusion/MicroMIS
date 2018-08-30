package MicroMis::Controller::User;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $c = shift;
  
  my $users = $c->db->get_collection('users');
  my @all_users = $users->find({ });
  
  $c->render(
    json   => \@all_users,
    status => 200
  );
}

1;