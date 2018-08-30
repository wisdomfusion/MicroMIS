# MicroMIS

**Micro Management Information System** for information with dynamic fields, using Perl and [Mojolicious](https://mojolicious.org/), with MongoDB as backend database.

## INSTALLATION

### Install Perl on macOS or Linux

```sh
$ \curl -L https://install.perlbrew.pl | bash
$ source ~/perl5/perlbrew/etc/bashrc
$ echo 'source ~/perl5/perlbrew/etc/bashrc' >> ~/.bash_profile
$ perlbrew init
$ perlbrew install perl-5.28.0
$ perlbrew switch perl-5.28.0
$ perlbrew install-cpanm
```


### Install Perl on Windows

Install [Strawberry Perl](http://strawberryperl.com/) or [ActiveState Perl](http://www.activestate.com/activeperl/downloads) first.

```sh
cpan App::cpanminus
```

### Init and run the application

```sh
$ cd MicroMIS/
$ cpanm --installdeps .
$ morbo script/app.pl
```

### Client Interface (React)

```sh
cd client/
npm i yarn
yarn install
yarn build
```
