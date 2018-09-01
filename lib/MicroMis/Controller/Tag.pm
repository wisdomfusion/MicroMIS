package MicroMis::Controller::Tag;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $c = shift;
  
  my $tags   = $c->db->get_collection('tags');
  my @result = $tags->find({ });
  
  $c->render(
    json   => { nodes => \@result },
    status => 200
  );
}

1;