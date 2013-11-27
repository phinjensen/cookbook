package Cookbook::Account;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::Passphrase;
use Dancer::Plugin::ValidateTiny;

use utf8;

get '/register' => sub {
    if (session('user')) {
        template 'register', { error => 'You are already logged in!' };
    } else {
        template 'register';
    }
};

post '/register' => sub {
    my $params = params;
    my $data_valid = 0;

    # Validating params with rule file
    my $data = validator($params, 'register.pl');

    if ($data->{valid}) {
        my $new_user = schema->resultset('User')->create({
            name  => params->{user},
            email => params->{email},
            password => my $phrase = passphrase(params->{pass})->generate->rfc2307
        });
        $new_user->update;
        template 'register', { success => 1 };
    } else {
        foreach my $key ( keys %{ $data->{result} } ) {
            if ($key =~ /err_.+/) {
                return template 'register', { error => $data->{result}->{$key} };
                #return template 'register', { error => error_report($key) };
            }
        }
    }
};
 
get '/login' => sub {
    # Display a login page; the original URL they requested is available as
    # vars->{requested_path}, so could be put in a hidden field in the form
    if (session('user')) {
        template 'login', { error => 'You are already logged in!' };
    } else {
        template 'login';
    }
};
 
post '/login' => sub {
    # Validate the username and password they supplied
    my $user = schema->resultset('User')->search({ name => params->{user} })->first;
    my $password = $user->password;
    if (passphrase(params->{pass})->matches($password)) {
        session user => params->{user};
        session logged_in => true;
        redirect params->{path} || '/';
    } else {
        redirect '/login?failed=1';
    }
};

get '/logout' => sub {
    session->destroy;
    template 'alert', { message => "You have been successfully logged out!" }
}
