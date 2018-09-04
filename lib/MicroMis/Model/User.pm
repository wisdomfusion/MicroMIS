package MicroMis::Model::User;

use strict;
use warnings;

use base qw( MicroMis::Model::Base );

sub collection { 'users' };

sub hidden_fields { qw( pass ) }

1;