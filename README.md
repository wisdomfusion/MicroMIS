# MicroMIS

**Micro Management Information System** for information with dynamic fields, using Perl and [Mojolicious](https://mojolicious.org/), with MongoDB as backend database.

## 1. INSTALLATION

### 1.1 Install Perl

**macOS or Linux**

```sh
$ \curl -L https://install.perlbrew.pl | bash
$ source ~/perl5/perlbrew/etc/bashrc
$ echo 'source ~/perl5/perlbrew/etc/bashrc' >> ~/.bash_profile
$ perlbrew init
$ perlbrew install perl-5.28.0
$ perlbrew switch perl-5.28.0
$ perlbrew install-cpanm
```


**Windows**

Install [Strawberry Perl](http://strawberryperl.com/) or [ActiveState Perl](http://www.activestate.com/activeperl/downloads) first, and

```sh
cpan App::cpanminus
```

### 1.2 Init and run the application

```sh
$ cd MicroMIS/
$ cpanm --installdeps .
$ morbo script/app.pl
```

### 1.3 Client Interface (React)

Install node.js 8+ first, and

```sh
cd client/
npm i yarn
yarn install
yarn build
```

## 2. INSTRUCTIONS


## 3. CONTRIBUTIONS

