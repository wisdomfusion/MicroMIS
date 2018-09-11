package MicroMis::Util;

use strict;
use warnings;

use Crypt::Eksblowfish::Bcrypt qw( bcrypt_hash en_base64 );
use Carp qw( croak );
use Exporter 'import';
our @EXPORT_OK = qw( encrypt_password check_password );

# Encrypt a password
sub encrypt_password {
    my $password = shift;
    my $salt = shift || _salt();

    # Encrypt the password
    my $hash = bcrypt_hash(
        {   key_nul => 1,
            cost    => 8,
            salt    => $salt,
        },
        $password
    );

    # Return the salt and the encrypted password
    return join('-', $salt, en_base64($hash));
}

# Check if the passwords match
sub check_password {
    my ($plain_password, $hashed_password) = @_;
    my ($salt) = split('-', $hashed_password, 2);
    return encrypt_password($plain_password, $salt) eq $hashed_password;
}

# Return a random salt
sub _salt {
    my $itoa64
        = './0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    my $salt = '';
    $salt .= substr($itoa64, int(rand(64)), 1) while length($salt) < 16;

    return $salt;
}

1;
